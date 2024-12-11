#! /usr/bin/env ruby
## -*- mode: ruby; coding: utf-8 -*-
## = Set Numbering Utility
## Author:: Itsuki Noda
## Version:: 0.0 2024/12/11 I.Noda
##
## === History
## * [2024/12/11]: Create This File.
## * [YYYY/MM/DD]: add more
## == Usage
## * ...

def $LOAD_PATH.addIfNeed(path, lastP = false)
  existP = self.index{|item| File.identical?(File.expand_path(path),
                                             File.expand_path(item))} ;
  if(!existP) then
    if(lastP) then
      self.push(path) ;
    else
      self.unshift(path) ;
    end
  end
end

$LOAD_PATH.addIfNeed("~/lib/ruby");
$LOAD_PATH.addIfNeed(File.dirname(__FILE__));

require 'pp' ;

#--======================================================================
#++
## 集合数値化
class SetNumbering
  #--::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
  #++
  ## default values for WithConfParam#getConf(_key_).
#  DefaultConf = { :bar => :baz } ;
  ## the list of attributes that are initialized by getConf().
#  DirectConfAttrList = [:bar] ;
  
  #--@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
  #++
  ## 原子リスト
  attr :atomList, true ;
  ## 原子表
  attr :atomTable, true ;

  #--------------------------------------------------------------
  #++
  ## 初期化
  ## _atomList_:: 原子項のリスト
  def initialize(_atomList)
    self.addAtomList(_atomList) ;
  end

  #------------------------------------------
  #++
  ## 原子項表の初期化
  ## _atomList_:: 原子項のリスト
  def addAtomList(_atomList)
    @atomList = [] if(@atomList.nil?) ;
    @atomTable = {} if(@atomTable.nil?) ;
    _atomList.each{|_atom|
      self.addAtom(_atom) ;
    }
    return @atomTable ;
  end
  
  #------------------------------------------
  #++
  ## 原子項表への追加
  ## _atom_:: 原子項
  ## *return*:: _atom_ に振られた番号
  def addAtom(_atom)
    if(@atomTable[_atom].nil?) then
      @atomTable[_atom] = @atomList.size() ;
      @atomList.push(_atom) ;
    end
    return @atomTable[_atom] ;
  end

  #--////////////////////////////////////////////////////////////
  #--------------------------------------------------------------
  #++
  ## 集合から自然数へ。
  ## _set_:: 変換する集合。リスト。昇順を仮定。
  ## _rank_:: 集合のランク（階層）。0 なら atom。
  ## *return*:: 変換された自然数。
  def setToNum(_set, _rank)
    if(_rank == 0) then
      return @atomTable[_set] ;
    else
      _num = 0 ;
      _set.each{|_element|
        _num += (2 ** self.setToNum(_element, _rank-1)) ;
      }
      return _num ;
    end
  end

  #--------------------------------------------------------------
  #++
  ## 自然数から集合へ。
  ## _num_:: 変換する数値。
  ## _rank_:: 集合のランク（階層）。0 なら atom。
  ## *return*:: 変換された集合
  def numToSet(_num, _rank)
    if(_rank == 0) then
      return @atomList[_num] ;
    else
      _set = [] ;
      (0..._num.bit_length()).each{|_k|
        _set.push(self.numToSet(_k, _rank-1)) if(_num[_k] == 1) ;
      }
      return _set ;
    end
  end

  #--////////////////////////////////////////////////////////////
  #--------------------------------------------------------------
  #++
  ## 数値のまま subset チェック
  ## _setNumA_::
  ## _setNumB_::
  ## *return*:: true if _setNumA_ is a subset of _setNumB_.
  def isSubSet(_setNumA, _setNumB)
    return ((_setNumA & _setNumB) == _setNumA) ;
  end

  #--------------------------------------------------------------
  #++
  ## 数値のまま subset チェック (byte 毎チェック)
  ## _setNumA_::
  ## _setNumB_::
  ## *return*:: true if _setNumA_ is a subset of _setNumB_.
  def isSubSetByByte(_setNumA, _setNumB, _byteWidth = 32)
    _bitLenA = _setNumA.bit_length() ;
    _bitLenB = _setNumB.bit_length() ;
    if(_bitLenB < _bitLenA) then
      return false ;
    else
      _bitPos = 0 ;
      while(_bitPos < _bitLenA)
        _byteA = _setNumA[_bitPos, _byteWidth] ;
        _byteB = _setNumB[_bitPos, _byteWidth] ;
        return false if((_byteA & _byteB) != _byteA)
        _bitPos += _byteWidth ;
      end
      return true ;
    end
  end

  #--------------------------------------------------------------
  #++
  ## 集合として subset チェック。ソートされていると仮定。
  def isSubSetBySet(_setA, _setB)
    _idxA = 0 ;
    _idxB = 0 ;
    while(_idxA < _setA.size)
      return false if(_idxB >= _setB.size) ;
      case(_setA[_idxA] <=> _setB[_idxB])
      when -1;
        return false ;
      when 0;
        _idxA += 1;
        _idxB += 1 ;
      when 1 ;
        _idxB += 1;
      else
        raise "something wrong: " + _setA.inspect + _setB.insepct ;
      end
    end
    return true ;
  end
  
  #--------------------------------------------------------------
  #++
  ## description of method foo
  ## _bar_:: about argument bar
  ## *return*:: about return value
#  def foo(bar, &block) # :yield: arg1, arg2
#  end

  #--////////////////////////////////////////////////////////////
  #--============================================================
  #--::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
  #--@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
  #--------------------------------------------------------------
end # class SetNumbering

########################################################################
########################################################################
########################################################################
if($0 == __FILE__) then

  require 'test/unit'

  #--============================================================
  #++
  # :nodoc:
  ## unit test for this file.
  class TC_Foo < Test::Unit::TestCase
    #--::::::::::::::::::::::::::::::::::::::::::::::::::
    #++
    ## desc. for TestData
    TestData10 = (0...10).map{|k| ("a%03d" % k).intern} ;

    #----------------------------------------------------
    #++
    ## show separator and title of the test.
    def setup
#      puts ('*' * 5) + ' ' + [:run, name].inspect + ' ' + ('*' * 5) ;
      name = "#{(@method_name||@__name__)}(#{self.class.name})" ;
      puts ('*' * 5) + ' ' + [:run, name].inspect + ' ' + ('*' * 5) ;
      super
    end

    #----------------------------------------------------
    #++
    ## about test_a
    def test_a
      sNum = SetNumbering.new(TestData10) ;
      wholeSubSet = [] ;
      (0..TestData10.size).each{|k|
        TestData10.combination(k).each{|subset| wholeSubSet.push(subset)}
      }
      wholeSubSet.each{|subset|
        p [:rank1, sNum.setToNum(subset, 1), subset] ;
      }
      wholeSubSet.combination(3).each{|sss|
        p [:rank2, sNum.setToNum(sss, 2), sss] ;
      }
    end

    #----------------------------------------------------
    #++
    ## about test_a
    def test_b
      sNum = SetNumbering.new(TestData10) ;
      wholeSubSet = [] ;
      (0..TestData10.size).each{|k|
        TestData10.combination(k).each{|subset| wholeSubSet.push(subset)}
      }

      testList = (0...1000).map{
        l = wholeSubSet.size ;
        indexListA = (0...5).map{ rand(wholeSubSet.size) }.sort.uniq ;
        indexListB = (0...(l-5)).map{ rand(wholeSubSet.size) }.sort.uniq ;
        sssA = indexListA.map{|k| wholeSubSet[k]}.sort ;
        sssB = indexListB.map{|k| wholeSubSet[k]}.sort ;
        [ sssA, sssB, sNum.setToNum(sssA,2), sNum.setToNum(sssB,2) ] 
      }

#      ans = testList.map{|(setA, setB, numA, numB)|
#        if(sNum.isSubSet(numA, numB)) then
#          p [:A, setA, numA] ;
#          p [:B, setB, numB] ;
#          p [:ans,
#             sNum.isSubSet(numA, numB),
#             sNum.isSubSetByByte(numA, numB),
#             sNum.isSubSetBySet(setA, setB),
#            ]
#        end
#      }

      nofTest = 100 ;
      
      startX = Time.now() ;
      (0...nofTest).each{
        testList.map{|(setA, setB, numA, numB)|
          sNum.isSubSet(numA, numB) }
      }
      endX  = Time.now() ;

      startY = Time.now() ;
      (0...nofTest).each{
        testList.map{|(setA, setB, numA, numB)|
          sNum.isSubSetByByte(numA, numB, 2**10) }
      }
      endY  = Time.now() ;

      startZ = Time.now() ;
      (0...nofTest).each{
        testList.map{|(setA, setB, numA, numB)|
          sNum.isSubSetBySet(setA, setB) }
      }
      endZ = Time.now() ;
      

      pp [:X, endX - startX]
      pp [:Y, endY - startY] ;
      pp [:Z, endZ - startZ] ;
      
    end
    ## result: 
    ## [:X, 0.023880103]
    ## [:Y, 0.139487007]
    ## [:Z, 9.039504691]

  end # class TC_Foo < Test::Unit::TestCase
end # if($0 == __FILE__)
