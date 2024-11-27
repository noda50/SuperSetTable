#! /usr/bin/env ruby
## -*- mode: ruby; coding: utf-8 -*-
## = SuperSet table class
## Author:: Itsuki Noda
## Version:: 0.0 2024/11/27 I.Noda
##
## === History
## * [2024/11/27]: Create This File.
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

require 'SuperSetList.rb' ;

#--======================================================================
#++
## class for SuperSet table
class SuperSetTable
  #--::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
  #++
  ## default values for WithConfParam#getConf(_key_).
#  DefaultConf = { :bar => :baz } ;
  ## the list of attributes that are initialized by getConf().
#  DirectConfAttrList = [:bar] ;
  
  #--@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
  #++
  ## description of attribute foo.
  attr :listTable, true ;
  ## root list
  attr :rootList, true ;

  #--------------------------------------------------------------
  #++
  ## initialize
  ## _rootList_:: root set of atoms
  def initialize(_rootList)
    @rootList = _rootList ;
    @listTable = {} ;
    self.addList(SuperSetList.newRootList(@rootList)) ;
  end

  #--------------------------------------------------------------
  #++
  ## add list
  ## _setList_:: a SuperSetList
  def addList(_setList)
    @listTable[_setList.seedSet()] = _setList ;
  end

  #--------------------------------
  #++
  ## add new list
  ## _motherList_:: a SuperSetList
  ## _atomList_:: a list of atoms to add to the seed set.
  ## *return*:: a new list ;
  def addNewList(_motherList, _atomList)
    _newList = SuperSetList.new(_motherList, _atomList) ;
    addList(_newList) ;
    return _newList ;
  end

  #--------------------------------
  #++
  ## add new list
  ## _seedSet_:: a seed set
  ## _autoNewP_:: a flag to force to create new list if not exists.
  ## *return*:: a SuperSetList.
  def getList(_seedSet, _autoNewP = false)
    _list = @listTable[_seedSet] ;
    
    if(_list.nil? && _autoNewP) then
      (_subSeedSet, _diffAtomList) = self.findLargestSubSeedSet(_seedSet) ;
      _list = self.addNewList(getList(_subSeedSet, false), _diffAtomList) ;
    end

    return _list ;
  end

  #--------------------------------
  #++
  ## []
  ## _seedSet_:: a seed set
  ## *return*:: a SuperSetList.
  def [](_seedSet)
    return getList(_seedSet, false) ;
  end

  #--------------------------------
  #++
  ## find largest subset as seedSet in table key.
  ## _seedSet_:: a seed set
  ## *return*:: a new list ;
  def findLargestSubSeedSet(_seedSet)
    _n = _seedSet.size() ;
    while(_n > 0)
      _n -= 1 ;
      _seedSet.combination(_n){|_seedSubSet|
        if(@listTable.has_key?(_seedSubSet)) then
          _diffAtomList = setDiff(_seedSet, _seedSubSet) ;
          return [_seedSubSet, _diffAtomList] ;
        end
      }
    end
    return nil ;
  end

  #--------------------------------
  #++
  ## set diff
  ## _largerSet_:: an atom list.
  ## _smallerSet_:: an atom list.  Should be a subset of _largerSet_.
  ## *return*:: a list of diff.
  def setDiff(_largerSet, _smallerSet)
    _diff = [] ;
    _largerSet.each{|_atom|
      _diff.push(_atom) if(! _smallerSet.include?(_atom)) ;
    }
    return _diff ;
  end

  #--------------------------------------------------------------
  #++
  ## each entry.
  def each(&_block) # :yield: _seedSet_, _setList_
    @listTable.each{|_seedSet, _setList|
      _block.call(_seedSet, _setList) ;
    }
  end

  #--////////////////////////////////////////////////////////////
  #--============================================================
  #--::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
  #--@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
  #--------------------------------------------------------------
end # class SuperSetTable

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
    TestData = nil ;

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
    ## simple test
    def test_a
      atomList = [:a, :b, :c, :d, :e, :f] ;
      n = 10 ;
      rootList = genCombList(atomList, n) ;

      ssTable = SuperSetTable.new(rootList) ;

      count = 0 ;
      max = 10 ;
      rootList.each{|aSet|
        count += 1 ;
        ssTable.getList(aSet, true).each{|set|
          p [count, aSet, set] ;
        }
        break if(count >= 10) ;
      }
#      pp ssTable ;
      
    end

    #----------------------
    def genCombList(atomList, nofDrop = 0)
      combList = [] ;
      (0..atomList.size).each{|k|
        combList.concat(atomList.combination(k).to_a) ;
      }
      (0...nofDrop).each{
        r = rand(combList.size) ;
        combList.delete_at(r) ;
      }
      return combList ;
    end

    #----------------------
    def genCombList2(atomList, dropProb = 0.0)
      combList = [] ;
      (0..atomList.size).each{|k|
        combList.concat(atomList.combination(k).to_a) ;
      }
      nofDrop = (combList.size.to_f * dropProb).to_i ;
      (0...nofDrop).each{
        r = rand(combList.size) ;
        combList.delete_at(r) ;
      }
      return combList ;
    end

    #----------------------------------------------------
    #++
    ## count test
    def test_b
#      atomList = [:a, :b, :c, :d, :e, :f] ;
#      atomList = [:a, :b, :c, :d, :e, :f, :g, :h, :i, :j, :k] ;
#      atomList = [:a, :b, :c, :d, :e, :f, :g, :h, :i, :j, :k, :l, :m, :n,
#                  :o, :p, :q, :r, :s, :t, :u, :v, :w, :x, :y, :z] ; 
      atomList = [:a, :b, :c, :d, :e, :f, :g, :h, :i, :j, :k, :l, :m, :n] ;

      n = 10 ;
      rootList = genCombList(atomList, n) ;

      ssTable = SuperSetTable.new(rootList) ;

      checkCount = 0 ;
      rootList.each{|zSet|
        next if(zSet.size == 0) ;
        zSet.each{|q|
          zSubSet = zSet.dup ;
          zSubSet.delete(q) ;
          ssTable.getList(zSubSet, true).each{|set|
            checkCount += 1;
          }
        }
      }

      size = rootList.size ;
      p [:result, :count, checkCount, size, checkCount.to_f / (size * size)] ;
    end

    #----------------------------------------------------
    #++
    ## count test 2
    def test_c
#      atomList = [:a, :b, :c, :d, :e, :f] ;
#      atomList = [:a, :b, :c, :d, :e, :f, :g, :h, :i, :j, :k] ;
#      atomList = [:a, :b, :c, :d, :e, :f, :g, :h, :i, :j, :k, :l, :m, :n,
#                  :o, :p, :q, :r, :s, :t, :u, :v, :w, :x, :y, :z] ; 
      atomList = [:a, :b, :c, :d, :e, :f, :g, :h, :i, :j, :k, :l, :m, :n,
                  :o, :p, :q,
                 ] ;

      prob = 0.5 ;
      rootList = genCombList2(atomList, prob) ;

      ssTable = SuperSetTable.new(rootList) ;

      checkCount = 0 ;
      zSetCount = 0 ;
      startTime = Time.now() ;
      preTime = Time.now() ;
      rootList.each{|zSet|
        zSetCount += 1 ;
        next if(zSet.size == 0) ;
        listSize = 0 ;
        zSet.each{|q|
          zSubSet = zSet.dup ;
          zSubSet.delete(q) ;
          ssTable.getList(zSubSet, true).each{|set|
            checkCount += 1;
            listSize += 1 ;
          }
        }
        cycleTime = Time.now() ;
        p [:cycle_zSet, zSetCount, ssTable.listTable.size,
           listSize, checkCount,
           cycleTime - startTime, cycleTime - preTime] ;
        preTime = cycleTime ;
      }

      size = rootList.size ;
      p [:result, :count, checkCount, size, checkCount.to_f / (size * size)] ;
    end
    

  end # class TC_Foo < Test::Unit::TestCase
end # if($0 == __FILE__)
