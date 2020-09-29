import os
import sys
import itertools as its
import ast
import csv
import time
import re
from datetime import datetime, timedelta
import uuid

sub_dir = 'modded/'
if not os.path.exists(sub_dir): os.mkdir(sub_dir)


def lineex(j, rline, outfile):  
    # ID = uuid.uuid4().hex
    
    with open(outfile, 'a',encoding='utf-8-sig', newline='\n') as g:
        g.write(str(j) + ',' + rline)
        
        

def main(args):
    infile = args[0]
    print('start time: {}'.format(datetime.now().strftime("%Y-%m-%d-%H.%M.%S")))
    
    outfile = sub_dir + re.sub('.csv', '-mod.csv', infile)
    with open(outfile ,'w') as ou, open(infile, 'r', encoding='utf-8') as rawfile:
        headers = rawfile.readline()
        ou.write('row_id,' + headers)
        row_count = sum(1 for row in rawfile)
    print('total rows:', row_count) 
        
    j = 0
    start_time = time.time()
    with open(infile, 'r') as rawfile:
        line = rawfile.readline() # skip headers
        while line:
            for _ in range(1000000):
                line = rawfile.readline()
                j += 1
                lineex(j, line, outfile)
                
            print('\t[{}] completed {} out of {} lines  [{}%]\n\t\tfiletime:{}'.format(infile, j, row_count, round(100*j/row_count), timedelta(seconds=int(time.time() - start_time))))
            print('\t\tfile ETC: {}\n\t\tlines/sec: {}'.format(timedelta(seconds=int((time.time() - start_time)*(row_count/j))), j/int(time.time() - start_time)))
    
    print('finished. end time: {}'.format(datetime.now().strftime("%Y-%m-%d-%H.%M.%S")))
    print('completed in {}'.format(timedelta(seconds=int(time.time() - start_time))))


if __name__ == '__main__':
    main(sys.argv[1:])
 
