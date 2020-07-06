#############
# Michael Thompson
# Input: music file 
# Output: the music's bpm
# Uses aubio, numpy, os libraries and ffmpeg
# Adapted from aubio example library
#
# Song path must be defined before using
##############


from aubio import source, tempo
from numpy import median, diff
import os
from pydub import AudioSegment

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
	samplerate, win_s, hop_s = 0, 256, 256

	# User-supplied music file path
	# uses relative path from working directory
	dirname = os.path.abspath(os.path.dirname(__file__))
	path = os.path.join(dirname, 'testfiles/thriller.mp3')

	# Converts input audio file to .wav format for processing with aubio
	# TODO do ffprobe to bypass conversion if input is already .wav
	file = AudioSegment.from_file(path)
	file.export ('file.wav', format='wav')


	# Imports file created from audiosegment
	#s = source('file.wav', samplerate, hop_s)
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
	        #if o.get_confidence() > .2 and len(beats) > 2.:
	        #    break
	    total_frames += read
	    if read < hop_s:
	        break

	bpm = beats_to_bpm(beats, path)
	print("{:6s} {:s}".format("{:2f}".format(bpm), path))
