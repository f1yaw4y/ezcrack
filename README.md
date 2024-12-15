# ezcrack
Mass processing of pcap files for use with Hashcat

ezcrack is a script to automatically convert your cap/pcap files into hc22000 files and run them all through hashcrack one at a time

This script is meant to be used if you have a large number of pcap files and wish to use the same dictionary for all of them

This is a very inefficient way of cracking hashes, and should only be used if you have no better way of accomplishing this task. Sort of a "hail mary" if you've run out of options

Install and use:

'''
git clone https://github.com/f1yaw4y/ezcrack/
cd ezcrack
sudo chmod +x ezcrack.sh
./ezcrack.sh <pcap files>
'''

Note that your pcap files do not need to be passed as an argument. If you simply run ./ezcrack.sh, you will be prompted to drag your files into the terminal window

The script will sanitize the files and convert them to .hc22000 files and place them in /home/USER/hashes

After conversion is done, you will be prompted for a dictionary, and the converted hc files will be passed to hashcat with your dictionary. The results of hashcat will also be stored in the hashes folder
