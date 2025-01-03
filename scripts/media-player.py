#!/usr/bin/env python3

import gi
gi.require_version("Playerctl", "2.0")
from gi.repository import Playerctl, GLib
from gi.repository.Playerctl import Player  # type: ignore
import argparse
import logging
import sys
import signal
import json
import os
from typing import List

logger = logging.getLogger(__name__)

def signal_handler(sig, frame):
  # Handle termination signals gracefully.
  logger.info("Received signal to stop, exiting")
  sys.stdout.write("\n")
  sys.stdout.flush()
  sys.exit(0)

class PlayerManager:
  def __init__(self, selected_player=None, excluded_players=[]):
    self.manager = Playerctl.PlayerManager()
    self.loop = GLib.MainLoop()
    self.manager.connect("name-appeared", self.on_player_appeared)
    self.manager.connect("player-vanished", self.on_player_vanished)

    # Register signal handlers for termination
    signal.signal(signal.SIGINT, signal_handler)
    signal.signal(signal.SIGTERM, signal_handler)
    signal.signal(signal.SIGPIPE, signal.SIG_DFL)

    self.selected_player = selected_player
    self.excluded_players = excluded_players.split(',') if excluded_players else []

    self.init_players()

  def init_players(self):
    # Initialize players based on selection and exclusion criteria.
    for player in self.manager.props.player_names:
      if player.name not in self.excluded_players:
        if self.selected_player is None or self.selected_player == player.name:
          self.init_player(player)

  def run(self):
    # Start the GLib main loop.
    logger.info("Starting main loop")
    self.loop.run()

  def init_player(self, player):
    # Initialize a new media player.
    logger.info(f"Initialize new player: {player.name}")
    player_instance = Playerctl.Player.new_from_name(player)
    player_instance.connect("playback-status", self.on_playback_status_changed)
    player_instance.connect("metadata", self.on_metadata_changed)
    self.manager.manage_player(player_instance)
    self.on_metadata_changed(player_instance, player_instance.props.metadata)

  def get_players(self) -> List[Player]:
    # Retrieve the list of managed players.
    return self.manager.props.players

  def write_output(self, text, player):
    # Format and send output for the player status.
    logger.debug(f"Writing output: {text}")

    # Determine the tooltip based on playback status
    tooltip_status = f"<span color='#f38ba8'><b>Paused:</b> </span>" if player.props.status != "Playing" else ""

    # Construct tooltip with track info
    tooltip = f"{tooltip_status}{text}"
    output = {
      "text": text,
      "class": "custom-" + player.props.player_name,
      "alt": player.props.player_name,
      "tooltip": tooltip
    }

    sys.stdout.write(json.dumps(output) + "\n")
    sys.stdout.flush()

  def clear_output(self):
    # Clear the output.
    sys.stdout.write("\n")
    sys.stdout.flush()

  def on_playback_status_changed(self, player, status, _=None):
    # Handle changes in playback status.
    logger.debug(f"Playback status changed for player {player.props.player_name}: {status}")
    self.on_metadata_changed(player, player.props.metadata)

  def get_first_playing_player(self):
    # Return the first player that is currently playing.
    players = self.get_players()
    logger.debug(f"Getting first playing player from {len(players)} players")
    
    for player in players[::-1]:
      if player.props.status == "Playing":
        return player
        
    return players[0] if players else None

  def show_most_important_player(self):
    # Display the most relevant player information.
    logger.debug("Showing most important player")
    current_player = self.get_first_playing_player()
    
    if current_player is not None:
      self.on_metadata_changed(current_player, current_player.props.metadata)
    else:
      self.clear_output()

  def on_metadata_changed(self, player, metadata, _=None):
    logger.debug(f"Metadata changed for player {player.props.player_name}")
    player_name = player.props.player_name
    artist = player.get_artist()
    title = player.get_title()

    # Escape special characters in the title
    title = title.replace("&", "&amp;") if title else "Unknown Title"

    track_info = None
    if metadata:
      try:
        # Access track ID safely
        track_id_variant = metadata.lookup_value("mpris:trackid", GLib.VariantType("s"))
        track_id = track_id_variant.unpack() if track_id_variant else ""
        if player_name == "spotify" and ":ad:" in track_id:
          track_info = "Advertisement"
      except Exception as e:
        logger.error(f"Error accessing metadata for player {player_name}: {e}")
    
    # Fallback to artist and title
    if not track_info and artist and title:
      track_info = f"<b>{title}</b> - {artist}"
    elif not track_info:
      track_info = title

    if track_info:
      prefix = (
        f"<span color='#a6e3a1'>󰓇  </span>" if player.props.status == "Playing" and player_name == "spotify" else
        f"<span color='#f38ba8'>󰗃  </span>" if player.props.status == "Playing" and player_name == "firefox" else
        f"<span color='#b4befe'>\u200A󰏤 \u2009\u2009\u200A</span>"
      )
      track_info = prefix + track_info

    current_playing = self.get_first_playing_player()
    if current_playing is None or current_playing.props.player_name == player.props.player_name:
      self.write_output(track_info, player)

  def on_player_appeared(self, _, player):
    # Handle new player appearance.
    logger.info(f"Player has appeared: {player.name}")
    
    if player.name not in self.excluded_players:
      if self.selected_player is None or player.name == self.selected_player:
        self.init_player(player)

  def on_player_vanished(self, _, player):
    # Handle player disappearance.
    logger.info(f"Player {player.props.player_name} has vanished")
    self.show_most_important_player()

def parse_arguments():
  # Parse command-line arguments.
  parser = argparse.ArgumentParser()
  parser.add_argument("-v", "--verbose", action="count", default=0)
  parser.add_argument("-x", "--exclude", help="Comma-separated list of excluded players")
  parser.add_argument("--player", help="Specify player to listen to")
  parser.add_argument("--enable-logging", action="store_true", help="Enable logging to a file")
  return parser.parse_args()

def main():
  # Main function to initialize and run the player manager.
  arguments = parse_arguments()

  # Initialize logging if enabled
  if arguments.enable_logging:
    logfile = os.path.join(os.path.dirname(os.path.realpath(__file__)), "media-player.log")
    logging.basicConfig(
      filename=logfile,
      level=logging.DEBUG,
      format="%(asctime)s %(name)s %(levelname)s:%(lineno)d %(message)s"
    )

  # Set log level based on verbosity
  logger.setLevel(max((3 - arguments.verbose) * 10, 0))

  logger.info("Creating player manager")
  
  if arguments.player:
    logger.info(f"Filtering for player: {arguments.player}")
  if arguments.exclude:
    logger.info(f"Excluding players: {arguments.exclude}")

  player_manager = PlayerManager(arguments.player, arguments.exclude)
  player_manager.run()

if __name__ == "__main__":
  main()
