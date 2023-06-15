{-# LANGUAGE DefaultSignatures, InstanceSigs, MagicHash, MultiParamTypeClasses,
             TypeFamilies, TypeOperators #-}


module Data.Double.Conversion.Convertable
    ( Convertable(..)
    ) where
import Data.ByteString.Builder.Prim (primBounded)
import Data.Text (Text)
import Data.String (IsString)
import qualified Data.ByteString.Builder as BB (Builder)
import Data.ByteString.Builder (byteString)
import Data.ByteString (pack, ByteString)
import qualified Data.ByteString.Internal as B (ByteString(..))
import qualified Data.Text.Internal.Builder as T
import qualified Data.Text.Encoding as T
import qualified Data.Text as T
import Data.Text (Text)
import Numeric

-- | Type class for floating data types, that can be converted, using double-conversion library
--
-- Default instanced convert input to Double and then make Bytestring Builder from it.
--
-- list of functions :
--
-- toExponential:
-- Compute a representation in exponential format with the requested
-- number of digits after the decimal point. The last emitted digit is
-- rounded.  If -1 digits are requested, then the shortest exponential
-- representation is computed.
--
-- toPrecision:
-- Compute @precision@ leading digits of the given value either in
-- exponential or decimal format. The last computed digit is rounded.
--
-- toFixed:
-- Compute a decimal representation with a fixed number of digits
-- after the decimal point. The last emitted digit is rounded.
--
-- toShortest:
-- Compute the shortest string of digits that correctly represent
-- the input number.
--
-- Conversion to text via Builder (both in the in case of bytestring and text) in case of single number
-- is a bit slower, than to text or bytestring directly.
-- But conversion a large amount of numbers to text via Builder (for example using foldr) is much faster than direct conversion to Text (up to 10-15x).
--
-- The same works for bytestrings: conversion, for example, a list of 20000 doubles to bytestring builder 
-- and then to bytestring is about 13 times faster than direct conversion of this list to bytestring. 
--
-- Conversion to text via text builder is a little bit slower, than conversion to bytestring via bytestring builder. 


class (RealFloat a, IsString b) => Convertable a b where
  toExponential :: Int -> a -> b
  default toExponential :: b ~ BB.Builder => Int -> a -> b 
  toExponential digits d
    | digits == -1 = byteString . T.encodeUtf8 . T.pack $ showEFloat Nothing d ""
    | otherwise = byteString . T.encodeUtf8 . T.pack $ showEFloat (Just digits) d ""
    
  toPrecision :: Int -> a -> b
  default toPrecision :: b ~ BB.Builder => Int -> a -> b 
  toPrecision digits d = byteString . T.encodeUtf8 . T.pack $ showGFloat (Just digits) d ""

  toFixed :: Int -> a -> b
  default toFixed :: b ~ BB.Builder => Int -> a -> b 
  toFixed digits d = byteString . T.encodeUtf8 . T.pack $ showFFloat (Just digits) d ""

  toShortest :: a -> b
  default toShortest :: b ~ BB.Builder => a -> b 
  toShortest d = byteString . T.encodeUtf8 . T.pack $ showFFloat Nothing d ""

-- Instances

-- instance Convertable Double BB.Builder where
-- instance Convertable Float BB.Builder where
instance Convertable Double ByteString where
  toExponential = error ""
  toPrecision = error ""
  toFixed = error ""
  toShortest = error ""

-- instance Convertable Float B.ByteString where
instance Convertable Double Text where
  toExponential = error ""
  toPrecision = error ""
  toFixed = error ""
  toShortest = error ""

-- instance Convertable Float Text where
-- instance Convertable Double T.Builder where
-- instance Convertable Float T.Builder where
