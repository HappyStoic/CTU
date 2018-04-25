import SedmaDatatypes

instance Eq Rank 
    where
        (==) R7 R7 = True
        (==) R8 R8 = True
        (==) R9 R9 = True
        (==) R10 R10 = True
        (==) RJ RJ = True
        (==) RQ RQ = True
        (==) RK RK = True
        (==) RA RA = True
        (==) _ _ = False

instance Eq Suit where
    (==) Heart Heart = True
    (==) Diamond Diamond = True
    (==) Spade Spade = True
    (==) Club Club = True
    (==) _ _ = False 

instance Eq Card where
    (==) (Card a b) (Card c d) = and [a==c, b==d]  

type RoundWinner = (Team, Int)

(!=) :: Eq a => a -> a -> Bool
(!=) a b = a /= b

uniqueElem :: Eq a => [a] -> Bool
uniqueElem (x:xs) | x `elem` xs = False
                  | otherwise = uniqueElem xs
uniqueElem _ = True

swap :: Team -> Team
swap AC = BD
swap _ = AC

--ARGS: Cards in trick -> team on turn -> points in trick -> currently winning -> winning rank-> winner of the round
evalRound :: Cards -> Team -> Int-> Team -> Maybe Rank -> RoundWinner
evalRound [] _ points winner _ = (winner, points)
evalRound ((Card kind R10 ):xs) onTurn curPoints curWinner Nothing        = evalRound xs (swap onTurn) 1 curWinner (Just R10)
evalRound ((Card kind RA  ):xs) onTurn curPoints curWinner Nothing        = evalRound xs (swap onTurn) 1 curWinner (Just RA)
evalRound ((Card kind rank):xs) onTurn curPoints curWinner Nothing        = evalRound xs (swap onTurn) 0 curWinner (Just rank)
evalRound ((Card kind rank):xs) onTurn curPoints curWinner (Just winRank) = evalRound xs nTurn nPoints nWinner (Just winRank)
        where
            nTurn = swap onTurn
            nPoints = if(or[rank == R10, rank == RA]) then curPoints + 1 else curPoints
            nWinner = if(or[winRank == rank, rank == R7]) then onTurn else curWinner


--ARGS: TeamACHasWin -> TeamBDHasWin -> ACpoints -> BDpoints -> Total winner
getWinner :: Bool -> Bool -> Int -> Int -> Winner
getWinner _ False _ _ = (AC, Three)
getWinner False _ _ _ = (BD, Three)
getWinner _ _ 9 _ = (AC, Two)
getWinner _ _ _ 9 = (BD, Two)
getWinner _ _ abPoints bdPoints | abPoints > bdPoints = (AC, One)
                                | otherwise = (BD, One) 


replayIns :: Cards -> Bool -> Bool -> Int -> Int -> Team -> Winner
replayIns [] acWin bdWin acPoints bdPoints onTurn =  getWinner acWin bdWin acPoints bdPoints
replayIns deck acWin bdWin acPoints bdPoints onTurn = replayIns nextCards a b c d team
    where
        (curCards, nextCards) = splitAt 4 deck
        (team, points) = evalRound curCards onTurn 0 onTurn Nothing
        bonus = if(nextCards == []) then 1 else 0  -- Bonus points for the last trick
        a = if(team == AC) then True else acWin
        b = if(team == BD) then True else bdWin
        c = if(team == AC) then acPoints+points+bonus else acPoints
        d = if(team == BD) then bdPoints+points+bonus else bdPoints 

replay :: Cards -> Maybe Winner
replay xs | (length xs) != 32 = Nothing
          | not (uniqueElem xs) = Nothing
          | otherwise = Just (replayIns xs False False 0 0 AC)