# 2048 Data Visulisation

2048 is a single-player game with the aim of sliding matching tiles together, creating a new tile with double the value, to get the highest possible score before no more moves are possible. In this project I wanted to look at the results of different playstyles
of the game and how they compare using some visulisations. There were 3 parts that went into creating the final document: 

## The Game

The version of 2048 used for this project was written by me, using Haskell and runs in terminal. This is human playable, and can be accessed by opening the haskell file, altering gameloopBot to gameloop as denoted in the code, and then running **cabal run x2048** in terminal. 

As far as I'm aware it should function almost identically to the original version of the game, with the exception of not having a small chance to randomly spawn in a 4-tile instead of a 2-tile.
## The Bots

In order to collect the data I used a short python script, with the subproccess model allowing me to repeatedly run and play the game automatically. In total there was 17 different weight combinations used with each one having 50 attempts at the game. Each turn
was added as a new row to the csv file, storing the score, turn number and weight combination.

## The Visulisations

First I made a few additional columns that weren't included the original csv I made, as well as a new table which just contains the final scores of each of the bots rather than every single turn.
I then used these tables to make some visulisations. This was all done in R, with the markdown script being availble in 2048_data_analysis. 

The types of graphs used include line graphs, bar graphs, box plots and scatter graphs. I tried to use a wide range   since I had both categorical data and numerical data to compare.
The main comparisons were drawn between the directions in which the bots favoured, and the strength of the preferences of the bots.

The results of the project can be found in visulisations.pdf which includes all code cells and finished graphs, as well as a few summary tables for the data and some text explaining common trends and comparing the performance of the different types of bots.  
