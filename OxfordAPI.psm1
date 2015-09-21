#Requires -Version 3

$OxfordClasses = @'
using System;
using System.Collections.Generic;
using System.Linq;
 
    namespace FR 
    {
        public class Rectangle 
        {
            public int? top { get; set; }
            public int? height { get; set; }
            public int? left { get; set; }
            public int? width { get; set; }
        }
        
        public class Face 
        {
            public string faceID { get; set; }
            public int? age {get; set; }
            public string gender {get; set; }
            public string filePath { get ; set; }
            public Rectangle faceRectangle {get ; set ; }
        }

        public class Person 
        {
            public int? PersonID { get; set; }
            public string Name { get; set; }
            public string UserData { get; set; }
            public List<Face> Faces { get; set; }
        }

        public class PersonGroup 
        {
            public int? PersonGroupID { get; set; }
            public List<Person> Persons { get; set; }
        }

    }//end namespace
'@
Add-Type -TypeDefinition $OxfordClasses -Language CSharpVersion3
Add-Type -AssemblyName System.Windows.Forms

function Add-Person
{
<#
.Synopsis
   Add a Person to Oxford API Database
.DESCRIPTION
   Add a person along with Face Ids and Description to person group.
   Only 1000 Persons are able to be created under the free API account.
   Each person can have 32 images to be stored for training. 
.EXAMPLE
   Add-Person -apiKey $ApiKey -personGroupId 1 -personName 'CJ' `
     -faceIDs $faceIDs -Description 'Test Person Added'
.EXAMPLE
   Add-Person -apiKey $ApiKey -personGroupId 1 -personName 'CJ'
.NOTES
   Created By George Rolston 9/20/2015
#>
    [CmdletBinding( 
                  SupportsShouldProcess=$true, 
                  ConfirmImpact='Medium')]
    PARAM(
        # API Key required to post to oxford project 
        [Parameter(Mandatory=$true, 
                   ValueFromPipeline=$false,
                   ValueFromPipelineByPropertyName=$false, 
                   ValueFromRemainingArguments=$false, 
                   Position=0)]
        [ValidateNotNullOrEmpty()]
        [string]$apiKey,
        # Group ID the Person will be added to for PersonGroup 
        [Parameter(Mandatory=$true, 
                   ValueFromPipeline=$false,
                   ValueFromPipelineByPropertyName=$false, 
                   ValueFromRemainingArguments=$false, 
                   Position=1)]
        [ValidateNotNullOrEmpty()]
        [int]$personGroupId,
        # Target person's display name. The maximum length is 128. 
        [Parameter(Mandatory=$true, 
                   ValueFromPipeline=$false,
                   ValueFromPipelineByPropertyName=$false, 
                   ValueFromRemainingArguments=$false, 
                   Position=2)]
        [ValidateLength(1,128)]
        [string]$personName,
                # Description of the Person Group. 
        [Parameter(Mandatory=$false, 
                   ValueFromPipeline=$false,
                   ValueFromPipelineByPropertyName=$false, 
                   ValueFromRemainingArguments=$false, 
                   Position=3)]
        [string]$Description = "Person created on $(Get-Date -Format "MM/dd/yyyy HH:mm")",
        # FaceIDs to associate with Person 
        [Parameter(Mandatory=$false, 
                   ValueFromPipeline=$false,
                   ValueFromPipelineByPropertyName=$false, 
                   ValueFromRemainingArguments=$false, 
                   Position=4)]
        [string[]]$faceIDs
        )

    BEGIN
    {

    }
    PROCESS
    {
        $Body = @{
                  "name" = $personName
                  "userData" = $Description
                  "faceIds" = $faceIDs
                  } | ConvertTo-Json
        $header = @{}
        $header.Add('Ocp-Apim-Subscription-Key', $ApiKey)
        $uri = 'https://api.projectoxford.ai/face/v0/persongroups/' + ($personGroupId).ToString() +'/persons' 
        try
        {
            $Post = Invoke-WebRequest -Method Post -Uri $uri -Headers $header -ContentType application/json -ErrorAction Stop -Body $Body
        }
        catch
        {
            Write-Error $_ -EA Stop
        }
    }#end PROCESS
    END
    {
        $Post.Content
    }#end END
}#end Add-Person

function Add-PersonGroup
{
<#
.Synopsis
   Add a Person Group to associate a person with
.DESCRIPTION
   Create a PersonGroup to add Persons to. A persongroup
   is required before you can add a Person to the 
   Oxford API database.
.EXAMPLE
   Add-PersonGroup -GroupName 'Admin Group'  `
     -Description 'The person group who are administrators' -ApiKey '123456789abcdefg'
.EXAMPLE
   Add-PersonGroup -GroupName 'My Friends' -ApiKey '123456789abcdefg'
.NOTES
   Created By George Rolston 9/5/2015
#>
    [CmdletBinding( 
                  SupportsShouldProcess=$true, 
                  ConfirmImpact='Medium')]
    PARAM(
        # GroupName is the Person group display name. The maximum length is 128. 
        [Parameter(Mandatory=$true, 
                   ValueFromPipeline=$false,
                   ValueFromPipelineByPropertyName=$false, 
                   ValueFromRemainingArguments=$false, 
                   Position=0)]
        [ValidateLength(1,128)]
        [string]$GroupName,
        # Description of the Person Group. 
        [Parameter(Mandatory=$false, 
                   ValueFromPipeline=$false,
                   ValueFromPipelineByPropertyName=$false, 
                   ValueFromRemainingArguments=$false, 
                   Position=1)]
        [string]$Description = "Person Group created on $(Get-Date -Format "MM/dd/yyyy HH:mm")",
        # API Key required to post to oxford project 
        [Parameter(Mandatory=$true, 
                   ValueFromPipeline=$false,
                   ValueFromPipelineByPropertyName=$false, 
                   ValueFromRemainingArguments=$false, 
                   Position=2)]
        [ValidateNotNullOrEmpty()]
        [string]$ApiKey
    )
    BEGIN {
        $personGroupId = 1
    }
    PROCESS{
        $Body = @{
                  "name" = $GroupName
                  "userData" = $Description
                  } | ConvertTo-Json
        $header = @{}
        $header.Add('Ocp-Apim-Subscription-Key', $ApiKey)
        $uri = 'https://api.projectoxford.ai/face/v0/persongroups/'  + $personGroupId
        try
        {
            $Post = Invoke-WebRequest -Method Put -Uri $uri -Headers $header -ContentType application/json -ErrorAction Stop -Body $Body
        }
        catch
        {
            Write-Error $_ -ErrorAction Stop
        }
    }#end PROCESS
    END{
        if($Post.Content){
            $Post.Content | ConvertFrom-Json
        }
    }#end END
}#end Add-PersonGroup

function Get-FaceDetection 
{
<#
.Synopsis
   Detect faces using Oxford API and image files
.DESCRIPTION
   Long description
.EXAMPLE
   Add-PersonGroup -GroupName 'Admin Group' -Description 'The person group who are administrators' -ApiKey '123456789abcdefg'
.EXAMPLE
   Add-Face -GroupName 'My Friends' -ApiKey '123456789abcdefg'
.INPUTS
   Inputs to this cmdlet (if any)
.OUTPUTS
   Output from this cmdlet (if any)
.NOTES
   Created By George Rolston 9/5/2015

#>
    [CmdletBinding( 
                  SupportsShouldProcess=$true, 
                  ConfirmImpact='Medium')]
    PARAM(
        # List of image file paths to load. 
        [Parameter(Mandatory=$true, 
                   ValueFromPipeline=$true,
                   ValueFromPipelineByPropertyName=$true, 
                   ValueFromRemainingArguments=$false, 
                   Position=0)]
        [ValidateScript( { $_ -LIKE "*.jpg"} ) ]
        [ValidateNotNullOrEmpty()]
        [string[]]$ImageFilePath,
        # API Key required to post to oxford project 
        [Parameter(Mandatory=$true, 
                   ValueFromPipeline=$false,
                   ValueFromPipelineByPropertyName=$false, 
                   ValueFromRemainingArguments=$false, 
                   Position=1)]
        [ValidateNotNullOrEmpty()]
        [string]$ApiKey
        )
    BEGIN{
        $Faces = @()
        $header = @{}
        $header.Add('Ocp-Apim-Subscription-Key', $ApiKey)
        $URI = 'https://api.projectoxford.ai/face/v0/detections?analyzesFaceLandmarks=true&analyzesAge=true&analyzesGender=true&analyzesHeadPose=true'
    }#end BEGIN

    PROCESS{
        foreach ($imageFile in $ImageFilePath)
        {
            $image = Invoke-WebRequest -Method Post -Uri $URI -Headers $header -ContentType application/octet-stream -InFile $imageFile
            $results = $image.Content | ConvertFrom-Json
            if($results.Count -GT 0)
            {
                $Person = New-Object Fr.Person 
                
                foreach($face in $results)
                {
                    $FRFace = New-Object FR.Face
                    $FRFace.faceId = $face.faceID
                    $FRFace.Age = $face.attributes.age
                    $FRFace.Gender = $face.attributes.gender
                    $FRFace.FilePath = $imageFile
       
                    #Face Rectangle - Not Implemented
                    <#
                    if($face.faceRectangle.top){
                    $FRFace.faceRectangle.top = $face.faceRectangle.top}
                    if($face.faceRectangle.left){
                    $FRFace.faceRectangle.left = $face.faceRectangle.left}
                    if($face.faceRectangle.width){
                    $FRFace.faceRectangle.width = $face.faceRectangle.width}
                    if($face.faceRectangle.height){
                    $FrFace.faceRectangle.height = $face.faceRectangle.height}
                    #>
            
                    # add result to be returned in the collection
                    $Faces += $FRFace
                }#end foreach face in result
            }#end if
        }#end foreach imageFilePath
    }#end PROCESS

    END{
        if($Faces.Count -GT 0)
        {
            return $Faces
        }
    }
}#end Get-FaceDetection