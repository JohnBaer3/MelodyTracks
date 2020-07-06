from aubio import source, tempo
from numpy import median, diff

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

	samplerate, win_s, hop_s = 44100, 1024, 512
	#samplerate, win_s, hop_s = 8000, 512, 128

	# User-supplied music file path
	# Must be .wav for now
	path = 

	s = source(path, samplerate, hop_s)

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
