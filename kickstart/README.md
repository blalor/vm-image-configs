These kickstart files are a bit of a shitshow.  The imgcreator-based ami-creator
doesn't recognize all of the %pre and %post sections the way that Anaconda does
when running from a CD.

Anaconda (used by virtualbox.cfg) runs the %post scripts in both common.cfg and
virtualbox.cfg, but ami-creator only runs the one from common.cfg.  ami-creator
doesn't seem to run *any* %pre scripts.
