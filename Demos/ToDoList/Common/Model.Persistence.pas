(*
  Copyright 2016, MARS-Curiosity library

  Home: https://github.com/andrea-magni/MARS
*)
unit Model.Persistence;

interface

uses
  Model;

type
  IPersistor<T, K> = interface
    function New(const AValue: T): K;
    function Retrieve(const AID: K): T;
    procedure Update(const AValue: T);
    procedure Delete(const AID: K);
  end;

implementation

end.
