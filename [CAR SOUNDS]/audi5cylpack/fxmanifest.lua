fx_version 'adamant'

game 'gta5'

files {
  'audioconfig/audiwx_game.dat151.rel',
  'audioconfig/audiwx_sounds.dat54.rel',
  'sfx/dlc_audiwx/audiwx.awc',
  'sfx/dlc_audiwx/audiwx_npc.awc',

  'audioconfig/audi7a_game.dat151.rel',
  'audioconfig/audi7a_sounds.dat54.rel',
  'sfx/dlc_audi7a/audi7a.awc',
  'sfx/dlc_audi7a/audi7a_npc.awc',

  'audioconfig/audiea855_game.dat151.rel',
  'audioconfig/audiea855_sounds.dat54.rel',
  'sfx/dlc_audiea855/audiea855.awc',
  'sfx/dlc_audiea855/audiea855_npc.awc'
}

data_file 'AUDIO_GAMEDATA' 'audioconfig/audiwx_game.dat'
data_file 'AUDIO_SOUNDDATA' 'audioconfig/audiwx_sounds.dat'
data_file 'AUDIO_WAVEPACK' 'sfx/dlc_audiwx'

data_file 'AUDIO_GAMEDATA' 'audioconfig/audi7a_game.dat'
data_file 'AUDIO_SOUNDDATA' 'audioconfig/audi7a_sounds.dat'
data_file 'AUDIO_WAVEPACK' 'sfx/dlc_audi7a'

data_file 'AUDIO_GAMEDATA' 'audioconfig/audiea855_game.dat'
data_file 'AUDIO_SOUNDDATA' 'audioconfig/audiea855_sounds.dat'
data_file 'AUDIO_WAVEPACK' 'sfx/dlc_audiea855'
client_script "@GRP-Anticheat/acloader.lua"