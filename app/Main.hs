module Main where

-----------
-- Imports
-----------
import System.Exit (exitSuccess)
import Control.Monad.Random (fromList,evalRandIO)
import Data.Maybe (isNothing)
import Control.Lens (element,set)
import System.Console.Haskeline(runInputT,defaultSettings,getInputChar)

---------------------
-- Type declarations
---------------------
type Cell = Maybe Int
type Row = [Cell]
type Grid = [Row]


-------------------------------------------
-- functions to allow user/bot to play the game
-------------------------------------------

-- On running, begins a new game with score = 0, and a blank board
main :: IO ()
main = do
    putStrLn "Press enter to start playing, and q to quit!"
    pos <- getLocationToInsert blankGrid
    weights <- getLine
    let j = read weights :: [Int] 
    let startingBoard = addRandomTile pos blankGrid
    printBoard startingBoard
    gameloop 0 j startingBoard  -- In order to play, delete 'Bot' from gameloopBot   

-- Score and board are use to store the current game states, and are updated every
-- iteration, as well as a random tile being added to the board
-- [Int] is there to have same type signature as the bot version
gameloop :: Int -> [Int] -> Grid -> IO()
gameloop score _ board =  do
    -- allows the user to make their move

   (newBoard,newScore) <- playTurn board
   -- Corrects the score as required
   let combScore = calcScore newBoard score + newScore

   -- adds in a random tile
   pos <- getLocationToInsert newBoard
   let updated =  addRandomTile pos newBoard

   -- if board full, ends the game, otherwise loops
   let isStuck = checkIfStuck updated
   if isStuck then putStrLn "Game over" >> printBoard updated >> putStrLn ("Your final score was :" ++ show combScore)
   else do
    printBoard updated
    putStrLn ("Current score : " ++ show combScore)
    gameloop combScore [] updated
   
gameloopBot :: Int -> [Int]  -> Grid -> IO()
gameloopBot score weights board =  do
    -- allows the user to make their move
   (newBoard,newScore) <- playTurnBot board weights
   -- Corrects the score as required
   let combScore = calcScore newBoard score + newScore

   -- adds in a random tile
   pos <- getLocationToInsert newBoard
   let updated =  addRandomTile pos newBoard

   -- if board full, ends the game, otherwise loops
   let isStuck = checkIfStuck updated
   if isStuck then putStrLn "Game over" >> printBoard updated >> putStrLn ("Your final score was : " ++ show combScore)
   else do
    printBoard updated
    putStrLn ("Current score : " ++ show combScore)
    gameloopBot combScore weights updated

-- takes an entered character, checks it's one we are expecting, and then
-- performs the necessary function
playTurn :: Grid -> IO (Grid,Int)
playTurn grid = do
    r <- validChar
    case r of
        "r" -> putStrLn "New Game :" >> return (blankGrid,0)
        "q" -> putStrLn "Thanks for playing" >> exitSuccess
        _ -> f (shift r grid)
    where f (altered,score) = if altered == grid then putStrLn "Can't move that way!" >> playTurn grid 
                      else return (altered,score)


playTurnBot :: Grid -> [Int] -> IO (Grid,Int)
playTurnBot grid weights = do 
    char <- evalRandIO(fromList (zip ['w','a','s','d'] (map fromIntegral weights)))
    f (shift [char] grid)
      where f (altered,score) = if altered == grid then putStrLn "Can't move that way!" >> playTurnBot grid weights
                               else return (altered,score)


----------------------------------
-- functions for managing the game
----------------------------------

-- Takes an empty location, and the current playing grid, and will 
-- add a '2' tile to the given location
addRandomTile :: (Int,Int) -> Grid -> Grid
addRandomTile (loc_a,loc_b) = set (element loc_a . element loc_b) (Just 2)

-- filters throught the grid to find the coordinates of empty cells
-- and randomly selects one of them to be used for insertion
getLocationToInsert :: Grid -> IO (Int,Int)
getLocationToInsert = f
  where getCoords r = zipWith zip r [[(i,j) | j <- [0..3] ]| i<- [0..3] ]
        findEmpty  =  map (map convert.filter (\(x,(i,j)) -> isNothing x))
        convert (Nothing,(x,y)) = ((x,y),1)
        getLocation = evalRandIO.fromList
        f = getLocation.concat.findEmpty.getCoords

-- checks if user input is a valid character, and 
-- returns the character if it's valid
validChar :: IO String
validChar = do
    char <- betterInputChar
    if char `elem` ['w','a','s','d','q','r'] 
        then pure [char] 
        else putStrLn "Not a valid entry, please try again" >> validChar


-- returns True if no more moves are possible 
checkIfStuck :: Grid -> Bool
checkIfStuck grid = case grid of
    [[Just a, Just b, Just c, Just d],
     [Just e, Just f, Just g, Just h],
     [Just i, Just j, Just k, Just l],
     [Just m, Just n, Just o, Just p]] ->  not $ any or (map check grid ++ map check (transpose grid))
    _ -> False
    where check xs = zipWith (==) xs (tail xs)

-- Needed so that we can reset the score
-- If the grid is empty, returns 0 otherwise returns input score
calcScore :: Grid -> Int -> Int
calcScore grid s = if grid == blankGrid then 0 else s
    
------------------
-- Row Operations
------------------

-- Merges a row together (BY DEFAULT GOES TO THE LEFT)
-- to merge to the right, reverse the input, then reverse after merging
-- [Just 2,Just 2,Nothing, Just 2] => [Just 4,Just 2]
mergeRow :: Row -> Row
mergeRow row  = case row of
    Nothing:xs -> mergeRow xs 
    x:Nothing:xs -> mergeRow (x:xs) 
    Just p : Just q : xs -> if p == q then Just (p*2) : mergeRow xs else Just p : mergeRow (Just q : xs) 
    xs -> xs

mergeRowScore :: Row -> Int 
mergeRowScore row = case row of 
    Nothing:xs -> mergeRowScore xs 
    x:Nothing:xs -> mergeRowScore (x:xs) 
    Just p : Just q : xs -> if p == q then p*2 + mergeRowScore xs  else mergeRowScore (Just q : xs)
    xs -> 0

shift :: String -> Grid  -> (Grid,Int)
shift "d" grid = (shiftRight grid, sum (map (mergeRowScore.reverse) grid))
shift "a" grid = (shiftLeft grid, sum (map mergeRowScore grid))
shift "w" grid = (shiftUp grid, sum (map mergeRowScore (transpose grid)))
shift "s" grid = (shiftDown grid, sum (map (mergeRowScore.reverse) (transpose grid)))
shift _ grid = (grid,0)


-- Shifts a grid right, left, up and down respectively
shiftRight :: Grid -> Grid
shiftRight = map (padding 'L'.reverse.mergeRow.reverse)

shiftLeft :: Grid -> Grid
shiftLeft = map (padding 'R'.mergeRow)

shiftUp :: Grid -> Grid
shiftUp = transpose.shiftLeft.transpose

shiftDown :: Grid -> Grid
shiftDown = transpose.shiftRight.transpose

-------------
-- Utilites
-------------

-- Increases the length of an input row to 4 by adding 
-- instances of Nothing to either the left ('L') or right ('R')
padding :: Char -> Row -> Row
padding 'L' x = replicate (4-length x) Nothing ++ x
padding 'R' x = x ++ replicate (4-length x) Nothing
padding _ x = x

-- Returns the transpose of the input grid
transpose :: Grid -> Grid
transpose = foldr f (repeat [])
   where f = zipWith (:)

-- prints out out the playing board in a nicer format
printBoard :: Grid -> IO ()
printBoard = mapM_ (print . map conv)
 where conv (Just x) = x
       conv Nothing = 0

-- Returns an empty 4x4 grid 
blankGrid :: Grid
blankGrid = [[Nothing | j <- [0..3] ]| i<- [0..3] ]


-- Will instantly read the input character, rather than requiring
-- enter to be pushed each time
betterInputChar :: IO Char
betterInputChar = do
    mc <- runInputT defaultSettings (getInputChar "")
    case mc of
     Nothing -> betterInputChar
     (Just c) -> return c