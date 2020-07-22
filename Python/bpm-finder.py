#############
# Michael Thompson
# Input: music file 
# Output: the music's bpm
# Uses aubio, numpy, os, sys, and ffmpeg (via pydub)
# Adapted from aubio example library
#
# Song path must be defined before using
#
# Created: 6/30/20
# Last Modified: 7/7/20
##############

from aubio import source, tempo
from numpy import median, diff
from pydub import AudioSegment
import os
import sys

# converts beats array to the song's BPM

def beats_to_bpm(beats, path):
    # if enough beats are found, convert to periods then to bpm
    if len(beats) > 1:
        if len(beats) < 4:
            print("few beats found in {:s}".format(path))
        bpms = 60./diff(beats)
        return median(bpms)
    else:
        print("not enough beats found in {:s}".format(path))
        return 0

if __name__ == '__main__':
	# Check for audio file
	if len(sys.argv) == 1:
		print("Must provide music file")
		sys.exit(1)

	# Check for too many program arguments
	if len(sys.argv) > 2:
		print("Too many arguments")
		sys.exit(1)


    # User-supplied music file path
	path = sys.argv[1]
	samplerate, win_s, hop_s = 0, 256, 256

	# Converts input audio file to .wav format for processing with aubio
	print('Converting song to wav...')
	file = AudioSegment.from_file(path)
	file.export ('file.wav', format='wav')

	# Imports file created from audiosegment
	print('Finding BPM...')
	s = source('file.wav', samplerate, hop_s)

	samplerate = s.samplerate

	o = tempo("specdiff", win_s, hop_s, samplerate)

	# List of beats, in samples
	beats = []
	
	# Total number of frames read
	total_frames = 0

	while True:
	    samples, read = s()
	    is_beat = o(samples)
	    if is_beat:
	        this_beat = o.get_last_s()
	        beats.append(this_beat)
	    total_frames += read
	    if read < hop_s:
	        break

	bpm = beats_to_bpm(beats, path)
	print("BPM:", "{:6s} {:s}".format("{:2f}".format(bpm),  path))
