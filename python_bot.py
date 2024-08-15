import pandas as pd
from subprocess import Popen, PIPE
import string

cmd = r"C:/Users/annab/OneDrive/Documents/coding projects/2048/dist-newstyle/build/x86_64-windows/ghc-9.4.7/x2048-0.1.0.0/x/x2048/build/x2048/x2048.exe"

def chunks(lst, n):
    # splits a list into chunks of size n
    for i in range(0, len(lst), n):
        yield lst[i:i + n]

def run_bot(cmd,weights):
    ps = Popen(cmd,stdout=PIPE,stdin=PIPE)
    o,e = ps.communicate(input=weights)
    return(str(o)[52:].split("\\r"))

NUMBER_OF_BOT_RUNS = 50

## Weights: All balanced, small/large preference for (w/a/s/d/(w,s)/(a,d)/(w,a)/(s,d))
testing_weights = ["[1,1,1,1]",
                   "[5,1,1,1]","[25,1,1,1]",
                   "[1,5,1,1]","[1,25,1,1]",
                   "[1,1,5,1]","[1,1,25,1]",
                   "[1,1,1,5]","[1,1,1,25]",
                   "[5,5,1,1]","[25,25,1,1]","[5,25,1,1]","[25,5,1,1]",
                   "[1,1,5,5]","[1,1,25,5]","[1,1,5,25]","[1,1,25,25]",]

rows = []

for tag, weights in zip(string.ascii_lowercase,testing_weights):
    print(weights)
    [w_weight,a_weight,d_weight,s_weight] = weights.split(",")

    for run,j in enumerate(range(0,NUMBER_OF_BOT_RUNS)):
        output = run_bot(cmd,weights.encode())
        filtered = list(filter((lambda x: x[2:5] != "Can" and x[2:5] != "Gam"),output))

        for turn, p in enumerate(chunks(filtered,5)):
            if len(p) > 1:
                score = p[4].split(":")[1][1:]
                rows.append([tag + str(run),turn,score,w_weight[1:],a_weight,d_weight,s_weight[:-1]])

df = pd.DataFrame(rows,columns=['Bot id','Turn no.','Current score','up weight','left weight', 'down weight', 'right weight'])
df.to_csv("bot_data.csv",index=False)

