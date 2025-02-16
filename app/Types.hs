{-# OPTIONS_GHC -Wno-incomplete-patterns #-}
module Types where

import Data.Complex
import RandomGen



type Point = Complex Double


-- ~coef * z + coef * ~z + free = 0
data Line = Line { coef :: Complex Double, free :: Double} deriving Show

data Circle = Circle { center :: Point, radiusSqr :: Double} deriving Show

data Shape = PointShape Point | LineShape Line | CircleShape Circle deriving Show



class IsShape a where
    fromShape :: Shape -> a
    toShape :: a -> Shape

instance IsShape Point where
    fromShape (PointShape p) = p
    toShape = PointShape

instance IsShape Line where
    fromShape (LineShape l) = l
    toShape = LineShape

instance IsShape Circle where
    fromShape (CircleShape c) = c
    toShape = CircleShape



class Builder f where
    mkBuilder :: f -> [Shape] -> [Rand Shape]


instance IsShape a => Builder [Rand a] where
    mkBuilder :: IsShape a => [Rand a] -> [Shape] -> [Rand Shape]
    mkBuilder randList _ = fmap (>>= pure . toShape) randList


instance (IsShape a, Builder f) => Builder (a -> f) where
    mkBuilder :: (IsShape a, Builder f) => (a -> f) -> [Shape] -> [Rand Shape]
    mkBuilder f (x : xs) = mkBuilder (f $ fromShape x) xs


class Checker f where
    mkChecker :: f -> [Shape] -> Bool

instance Checker Bool where
    mkChecker :: Bool -> [Shape] -> Bool
    mkChecker = const

instance (IsShape a, Checker f) => Checker (a -> f) where
    mkChecker :: (IsShape a, Checker f) => (a -> f) -> [Shape] -> Bool
    mkChecker f (x : xs) = mkChecker (f $ fromShape x) xs


data Command = Command { res :: String, args :: [String], action :: [Shape] -> [Rand Shape] }

data Conclusion = Conclusion { arguments :: [String], factChecker :: [Shape] -> Bool }

instance Show Command where
    show (Command r as _) = "Command " <> r <> " " <> show as

instance Show Conclusion where
    show (Conclusion as _) = "Conclusion " <> show as