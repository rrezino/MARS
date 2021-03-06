unit Resources.Razor;

interface

uses
  Classes, SysUtils
  , MARS.Core.Attributes
  , MARS.Core.MediaType
  , MARS.Core.Response

  , MARS.Core.URL

  , MARS.Core.Classes
  , MARS.Core.Engine
  , MARS.Core.Application

  , MARS.DelphiRazor.Resources
;

type
  [Path('razor')]
  TGalleryRazorResource = class(TRazorResource)
  protected
    [Context] App: TMARSApplication;
    function GetRootFolder: string;
    function CategoryFolder(const ACategoryName: string): string;

    function DoProvideContext(const APathInfo: string;
      const APathParam: string): TArray<TContextEntry>; override;
  public
  end;


implementation

uses
    IOUtils, DateUtils, Contnrs
  , MARS.Core.Registry
  , MARS.Core.Exceptions
  , MARS.Core.Utils
  , MARS.Rtti.Utils
  , Gallery.Model
;

{ TGalleryRazorResource }

function TGalleryRazorResource.CategoryFolder(
  const ACategoryName: string): string;
begin
  Result := TPath.Combine(GetRootFolder, ACategoryName);
end;

function TGalleryRazorResource.DoProvideContext(const APathInfo,
  APathParam: string): TArray<TContextEntry>;
var
  LObjectList: TObjectList;
  LCategoryList: TCategoryList;
  LItemsList: TItemList;
begin
  Result := inherited DoProvideContext(APathInfo, APathParam);

  if SameText(APathInfo, 'categories') then
  begin
    LCategoryList := TCategoryList.CreateFromFolder(GetRootFolder);
    try
      LObjectList := LCategoryList.ToObjectList;
      Result := Result + [TContextEntry.Create('categories', LObjectList)];
    finally
      LCategoryList.Free;
    end;
  end
  else if SameText(APathInfo, 'items') then
  begin
    LItemsList := TItemList.CreateFromFolder(CategoryFolder(APathParam));
    try
      LObjectList := LItemsList.ToObjectList;
      Result := Result + [TContextEntry.Create('items', LObjectList)];
    finally
      LItemsList.Free;
    end;
  end;
end;

function TGalleryRazorResource.GetRootFolder: string;
begin
  Result := App.Parameters.ByName('RootFolder'
    , TPath.Combine(ExtractFilePath(ParamStr(0)), 'root')).AsString;
end;

initialization
  TMARSResourceRegistry.Instance.RegisterResource<TGalleryRazorResource>(
    function: TObject
    begin
      Result := TGalleryRazorResource.Create;
    end
  );

end.
