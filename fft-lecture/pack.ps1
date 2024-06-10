$outFolders = ls | ? { $_.Name -eq "out" } | measure
if ($outFolders.Count -eq 0) {
    mkdir out
}

$outFolders = ls out | ? { $_.Name -eq "extension" } | measure
if ($outFolders.Count -eq 0) {
    mkdir "out/extension"
}

$outFolders = ls "out/extension" | ? { $_.Name -eq "syntaxes" } | measure
if ($outFolders.Count -eq 0) {
    mkdir "out/extension/syntaxes"
}

$contentTypes = ls out | ? { $_.Name -eq "[Content_Types].xml" } | measure
if ($contentTypes.Count -eq 0) {
    ni "out/[Content_Types].xml" -Value "<?xml version=""1.0"" encoding=""utf-8""?>
    <Types xmlns=""http://schemas.openxmlformats.org/package/2006/content-types"">
        <Default Extension="".json"" ContentType=""application/json""/>
        <Default Extension="".vsixmanifest"" ContentType=""text/xml""/>
        <Default Extension="".md"" ContentType=""text/markdown""/>
        <Default Extension="".js"" ContentType=""application/javascript""/>
    </Types>"
}

$nameLine = gc .\src\package.json | ? { $_.Contains("name") }
$name = $nameLine.Substring(13, $nameLine.Length - 13 - 2)

$manifests = ls out | ? { $_.Name -eq "extension.vsixmanifest" } | measure
if ($manifests.Count -ne 0) {
    del "out/extension.vsixmanifest"
}
ni "out/extension.vsixmanifest" -Value "<?xml version=""1.0"" encoding=""utf-8""?>
<PackageManifest Version=""2.0.0"" xmlns=""http://schemas.microsoft.com/developer/vsx-schema/2011"" xmlns:d=""http://schemas.microsoft.com/developer/vsx-schema-design/2011"">
    <Metadata>
        <Identity Language=""en-US"" Id=""$($name)"" Version=""0.0.1"" Publisher=""undefined"" />
        <DisplayName>$($name)</DisplayName>
        <Description xml:space=""preserve""></Description>
        <Tags></Tags>
        <Categories>Other</Categories>
        <GalleryFlags>Public</GalleryFlags>
        
        <Properties>
            <Property Id=""Microsoft.VisualStudio.Code.Engine"" Value=""^1.89.0"" />
            <Property Id=""Microsoft.VisualStudio.Code.ExtensionDependencies"" Value="""" />
            <Property Id=""Microsoft.VisualStudio.Code.ExtensionPack"" Value="""" />
            <Property Id=""Microsoft.VisualStudio.Code.ExtensionKind"" Value=""workspace"" />
            <Property Id=""Microsoft.VisualStudio.Code.LocalizedLanguages"" Value="""" />
            <Property Id=""Microsoft.VisualStudio.Services.GitHubFlavoredMarkdown"" Value=""true"" />
            <Property Id=""Microsoft.VisualStudio.Services.Content.Pricing"" Value=""Free""/>
        </Properties>
    </Metadata>
    
    <Installation>
        <InstallationTarget Id=""Microsoft.VisualStudio.Code""/>
    </Installation>

    <Dependencies/>
    
    <Assets>
        <Asset Type=""Microsoft.VisualStudio.Code.Manifest"" Path=""extension/package.json"" Addressable=""true"" />
        <Asset Type=""Microsoft.VisualStudio.Services.Content.Details"" Path=""extension/README.md"" Addressable=""true"" />
        <Asset Type=""Microsoft.VisualStudio.Services.Content.Changelog"" Path=""extension/CHANGELOG.md"" Addressable=""true"" />
    </Assets>
</PackageManifest>"

cp src/CHANGELOG.md out/extension/CHANGELOG.md
cp src/README.md out/extension/README.md
cp src/extension.js out/extension/extension.js
cp src/package.json out/extension/package.json
cp src/language-configuration.json out/extension/language-configuration.json
cp src/syntaxes/zerolang.tmLanguage.json out/extension/syntaxes/zerolang.tmLanguage.json

if ((ls | ? {$_.name -eq "$($name).zip"} | measure).Count -ne 0) {
    del "$($name).zip"
}
if ((ls | ? {$_.name -eq "$($name).vsix"} | measure).Count -ne 0) {
    del "$($name).vsix"
}
Compress-Archive .\out\* $name
rni "$($name).zip" "$($name).vsix"