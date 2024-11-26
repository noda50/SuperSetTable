#! /usr/bin/env ruby
## -*- mode: ruby; coding: utf-8 -*-
## = SuperSet List class
## Author:: Itsuki Noda
## Version:: 0.0 2024/11/26 I.Noda
##
## === History
## * [2024/11/26]: Create This File.
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
## SuperSet (上位集合) 探索リスト
class SuperSetList
  #--::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
  #++
  ## default values for WithConfParam#getConf(_key_).
#  DefaultConf = { :bar => :baz } ;
  
  #--@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
  #++
  ## known list
  attr :knownList, true ;
  ## mother list
  attr :motherList, true ;
  ## mother list index
  attr :motherIndex, true ;
  ## a list of atoms that should be included in a set.
  attr :addAtomList, true ;
  ## complete flag
  attr :isComplete, true ;

  #--------------------------------------------------------------
  #++
  ## initialize
  ## _motherList_:: a mother list. a SuperSetList
  ## _atomList_:: a list of adding atoms. an Array of atoms.
  ## _initIndex_:: initial mother index.
  def initialize(_motherList = nil,
                 _atomList = nil,
                 _initIndex = 0)
    @knownList = [] ;
    @motherList = _motherList ;
    @atomList = _atomList ;
    @motherIndex = _initIndex ;
    @isComplete = @motherList.nil?

    if(@motherList && @atomList.nil?) then
      raise "atomList is required to create #{self} instance." ;
    end
  end

  #--------------------------------
  #++
  ## set known list.
  ## _knowList_:: a known list ;
  def setKnownList(_knownList)
    @knownList = _knownList ;
  end

  #--------------------------------------------------------------
  #++
  ## initialize
  ## _motherList_:: a mother List
  ## _filter_:: filtering condition body. a Procedure
  ## _initIndex_:: initial mother index.
  def self.newBaseList(_baseList)
    _ssList = self.new() ;
    _ssList.setKnownList(_baseList) ;
    return _ssList ;
  end

  #--////////////////////////////////////////////////////////////
  #--------------------------------------------------------------
  #++
  ## pick-up nth element
  ## _n_:: an Integer
  ## *return*:: an element.  nil if the list is over.
  def nth(_n)
    if(_n >= @knownList.size && @isComplete) then
      return nil ;
    else
      until(_n < @knownList.size) 
        _candidate = @motherList.nth(@motherIndex) ;
        @motherIndex += 1 ;
        if(_candidate.nil?) then
          @isComplete = true ;
          return nil ;
        end
        ## check all of @atomList is included.
        _filterFlag = true ;
        @atomList.each{|_atom|
          if(!_candidate.include?(_atom)) then
            _filterFlag = false ;
            break ;
          end
        }
        @knownList.push(_candidate) if(_filterFlag) ;
      end
      return @knownList[_n] ;
    end
  end

  #--------------------------------------------------------------
  #++
  ## []
  def [](_n)
    return nth(_n) ;
  end
  
  #--------------------------------------------------------------
  #++
  ## each
  ## *return*:: about return value
  def each(&_block) # :yield: _set_
    _n = 0 ;
    while(true)
      _set = self[_n] ;
      _n += 1 ;
      break if(_set.nil?) ;
      _block.call(_set) ;
    end
  end

  #--////////////////////////////////////////////////////////////
  #--------------------------------------------------------------
  #++
  ## 最大積集合
  def intersectionSet()
    if(@atomList.nil?) then
      return [] ;
    else
      return @motherList.intersectionSet().concat(@atomList) ;
    end
  end
  
  #--////////////////////////////////////////////////////////////
  #--============================================================
  #--::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
  #--@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
  #--------------------------------------------------------------
end # class SuperSetList

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
    ## simple list test
    def test_a
      ssList0 = SuperSetList.newBaseList([:a, :b, :c]) ;
      ssList0.each{|set|
        pp set ;
      }
    end

    #----------------------------------------------------
    #++
    ## whole combination
    def test_b
      atomList = [:a, :b, :c, :d, :e, :f] ;
      combList = genBaseList(atomList) ;
      
      ssList0 = SuperSetList.newBaseList(combList) ;
      ssList1 = SuperSetList.new(ssList0, [:a]) ;
      ssList2 = SuperSetList.new(ssList1, [:b]) ;
      ssList3 = SuperSetList.new(ssList2, [:c]) ;
      ssList4 = SuperSetList.new(ssList3, [:e]) ;

      pp [:init, ssList4, :intersection, ssList4.intersectionSet()] ;

      k = 0 ;
      ssList4.each{|set|
#        p [k, set, ssList4] ;
        p [k, set] ;
        k += 1;
      }
    end

    #----------------------
    def genBaseList(atomList)
      combList = [] ;
      (0..atomList.size).each{|k|
        combList.concat(atomList.combination(k).to_a) ;
      }
      return combList ;
    end
    

  end # class TC_Foo < Test::Unit::TestCase
end # if($0 == __FILE__)
