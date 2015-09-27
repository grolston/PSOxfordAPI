#Requires -Version 3

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
        [Alias("userData")]
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

    }#end BEGIN
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
            $result = $Post.Content | ConvertFrom-Json
        }
        catch
        {
            Write-Error $_ -EA Stop
        }
    }#end PROCESS
    END
    {
        $result
    }#end END
}#end Add-Person
Export-ModuleMember -Function Add-Person

function Add-PersonFace 
{
<#
.Synopsis
   Adds a face to a person for identification
.DESCRIPTION
   Adds a face to a person for identification. The maximum face count for each 
   person is 32. The face ID must be added to a person before its expiration. 
   Typically a face ID expires 24 hours after detection. 
.EXAMPLE
   Add-PersonFace -ApiKey '123456789abcdefg' -faceId '123-1231-12232'  ` 
     -personId '123-452zaz-a123' -personGroupId 1 -faceDescription 'Test Face'
.NOTES
   Created By George Rolston 9/25/2015
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
        # The target faceId. 
        [Parameter(Mandatory=$true, 
                   ValueFromPipeline=$true,
                   ValueFromPipelineByPropertyName=$true, 
                   ValueFromRemainingArguments=$false, 
                   Position=1)]
        [ValidateNotNullOrEmpty()]
        [string]$faceId,
        # The target personId the face belongs to. 
        [Parameter(Mandatory=$true, 
                   ValueFromPipeline=$true,
                   ValueFromPipelineByPropertyName=$false, 
                   ValueFromRemainingArguments=$false, 
                   Position=2)]
        [ValidateNotNullOrEmpty()]
        [string]$personId,
        # The target person's belonging person group's ID. 
        [Parameter(Mandatory=$true, 
                   ValueFromPipeline=$false,
                   ValueFromPipelineByPropertyName=$false, 
                   ValueFromRemainingArguments=$false, 
                   Position=3)]
        [ValidateNotNullOrEmpty()]
        [int]$personGroupId,
        # user data to describe the face. 
        [Parameter(Mandatory=$true, 
                   ValueFromPipeline=$false,
                   ValueFromPipelineByPropertyName=$false, 
                   ValueFromRemainingArguments=$false, 
                   Position=4)]
        [ValidateNotNullOrEmpty()]
        [Alias("userData")]
        [string]$faceDescription
        )

    BEGIN
    {
        $body = @{
            'userData' = $faceDescription
        } | ConvertTo-JSON
        $header = @{}
        $header.Add('Ocp-Apim-Subscription-Key', $apiKey)
    }
    PROCESS{
        $uri = 'https://api.projectoxford.ai/face/v0/persongroups/'+ $personGroupId +'/persons/' + $personId + '/faces/' + $faceId
        try
        {
            $results = Invoke-WebRequest -Method Put -Uri $uri -Body $body -Headers $header -ContentType application/json -EA Stop
            $obj = $results.content | ConvertFrom-Json
        }
        catch
        {
            Write-error $_ -EA Stop
        }
    }#end PROCESS
    END
    {
        $obj
    }#end END
}#end Add-PersonFace
Export-ModuleMember -Function Add-PersonFace

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
        [Alias("userData")]
        [string]$Description = "Person Group created on $(Get-Date -Format "MM/dd/yyyy HH:mm")",
        # API Key required to post to oxford project 
        [Parameter(Mandatory=$true, 
                   ValueFromPipeline=$false,
                   ValueFromPipelineByPropertyName=$false, 
                   ValueFromRemainingArguments=$false, 
                   Position=2)]
        [ValidateNotNullOrEmpty()]
        [string]$apiKey
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
Export-ModuleMember -Function Add-PersonGroup

function Delete-Person
{
<#
.Synopsis
   Deletes an existing person from a person group.   
.DESCRIPTION
   Deletes an existing person from a person group.  
.EXAMPLE
   Delete-Person -personId '123-456-abc' -personGroupId 1
.NOTES
   Created By George Rolston 9/25/2015
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
        # Person ID to retrieve. 
        [Parameter(Mandatory=$true, 
                   ValueFromPipeline=$true,
                   ValueFromPipelineByPropertyName=$true, 
                   ValueFromRemainingArguments=$false, 
                   Position=1)]
        [ValidateNotNullOrEmpty()]
        [string]$personId,
        # List of image file paths to load. 
        [Parameter(Mandatory=$true, 
                   ValueFromPipeline=$false,
                   ValueFromPipelineByPropertyName=$false, 
                   ValueFromRemainingArguments=$false, 
                   Position=2)]
        [ValidateNotNullOrEmpty()]
        [int]$personGroupId
        )
    BEGIN{
        $header = @{}
        $header.Add('Ocp-Apim-Subscription-Key', $apiKey)
    }#end BEGIN
    PROCESS{
        $uri = 'https://api.projectoxford.ai/face/v0/persongroups/'+ $personGroupId +'/persons/' + $personId
        try
        {
            $results = Invoke-WebRequest -Method Delete -Uri $uri -Headers $header -ContentType application/json -EA Stop3
            $obj = $results.content | ConvertFrom-Json
        }
        catch
        {
            Write-error $_ -EA Stop
        }
    }#end PROCESS
    END{
        $obj
    }#end END
}#end Delete-Person
Export-ModuleMember -Function Delete-Person

function Delete-PersonFace
{
<#
.Synopsis
   Deletes a face from a person.    
.DESCRIPTION
   Deletes a face from a person.   
.EXAMPLE
   Delete-PersonFace -faceId '123-456-cde' -personId '123-456-abc' -personGroupId 1 -apiKey '123456789'
.NOTES
   Created By George Rolston 9/25/2015
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
        # The target faceId. 
        [Parameter(Mandatory=$true, 
                   ValueFromPipeline=$true,
                   ValueFromPipelineByPropertyName=$true, 
                   ValueFromRemainingArguments=$false, 
                   Position=1)]
        [ValidateNotNullOrEmpty()]
        [string]$faceId,
        # The target personId the face belongs to. 
        [Parameter(Mandatory=$false, 
                   ValueFromPipeline=$true,
                   ValueFromPipelineByPropertyName=$true, 
                   ValueFromRemainingArguments=$false, 
                   Position=2)]
        [ValidateNotNullOrEmpty()]
        [string]$personId,
        # The target person's belonging person group's ID. 
        [Parameter(Mandatory=$true, 
                   ValueFromPipeline=$false,
                   ValueFromPipelineByPropertyName=$false, 
                   ValueFromRemainingArguments=$false, 
                   Position=3)]
        [ValidateNotNullOrEmpty()]
        [int]$personGroupId
        )
    BEGIN{
        $header = @{}
        $header.Add('Ocp-Apim-Subscription-Key', $apiKey)
    }#end BEGIN
    PROCESS{
        $uri = 'https://api.projectoxford.ai/face/v0/persongroups/'+ $personGroupId +'/persons/' + $personId + '/faces/' + $faceId
        try
        {
            $results = Invoke-WebRequest -Method Delete -Uri $uri -Headers $header -ContentType application/json -EA Stop3
            $obj = $results.content | ConvertFrom-Json
        }
        catch
        {
            Write-error $_ -EA Stop
        }
    }#end PROCESS
    END{
        $obj
    }#end END

}#end Delete-PersonFace
Export-ModuleMember -Function Delete-PersonFace

function Delete-PersonGroup
{
<#
.Synopsis
   Deletes a PersonGroup.    
.DESCRIPTION
   Deletes a PersonGroup.   
.EXAMPLE
   Delete-PersonGroup -personGroupId 1 -apiKey '123456789'
.NOTES
   Created By George Rolston 9/25/2015
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
        # PersonGroupID to delete from API. 
        [Parameter(Mandatory=$true, 
                   ValueFromPipeline=$false,
                   ValueFromPipelineByPropertyName=$false, 
                   ValueFromRemainingArguments=$false, 
                   Position=1)]
        [int]$personGroupId
        )
    BEGIN{
        $header = @{}
        $header.Add('Ocp-Apim-Subscription-Key', $apiKey)
    }#end BEGIN
    PROCESS
    {
        $uri = 'https://api.projectoxford.ai/face/v0/persongroups/'+ $personGroupId 
        try
        {
            $results = Invoke-WebRequest -Method Delete -Uri $uri -Headers $header -ContentType application/json -EA Stop
            $obj = $results.content | ConvertFrom-Json
        }
        catch
        {
            Write-error $_ -EA Stop
        }
    }#end PROCESS
    END{
        $obj
    }#end END

}#end Delete-PersonGroup
Export-ModuleMember -Function Delete-PersonGroup

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
        [string[]]$imageFilePath,
        # API Key required to post to oxford project 
        [Parameter(Mandatory=$true, 
                   ValueFromPipeline=$false,
                   ValueFromPipelineByPropertyName=$false, 
                   ValueFromRemainingArguments=$false, 
                   Position=1)]
        [ValidateNotNullOrEmpty()]
        [string]$apiKey
        )
    BEGIN{
        $faces = @()
        $header = @{}
        $header.Add('Ocp-Apim-Subscription-Key', $ApiKey)
        $URI = 'https://api.projectoxford.ai/face/v0/detections?analyzesFaceLandmarks=true&analyzesAge=true&analyzesGender=true&analyzesHeadPose=true'
    }#end BEGIN

    PROCESS{
        foreach ($imageFile in $imageFilePath)
        {
            $image = Invoke-WebRequest -Method Post -Uri $URI -Headers $header -ContentType application/octet-stream -InFile $imageFile
            $results = $image.Content | ConvertFrom-Json
            $faces += $results

        }#end foreach imageFilePath
    }#end PROCESS

    END{
        $faces
    }
}#end Get-FaceDetection
Export-ModuleMember -Function Get-FaceDetection 

function Get-FaceGrouping
{
<#
.Synopsis
   Divides candidate faces into groups based on face similarity. 
.DESCRIPTION
   The output is one or more disjointed face groups and a MessyGroup. 
   A face group contains the faces that have similar looking, often 
   of the same person. There will be one or more face groups ranked 
   by group size, i.e. number of face.Faces belonging to the 
   same person might be split into several groups in the result. 
   The MessyGroup is a special face group that each face is not similar 
   to any other faces in original candidate faces. The messyGroup 
   will not appear in the result if all faces found their similar 
   counterparts. The candidate face list has a limit of 100 faces.
.EXAMPLE
   Get-FaceGrouping -faceIds $FaceIDs -ApiKey '123456789abcdefg'
.NOTES
   Created By George Rolston 9/25/2015
#>
    [CmdletBinding( 
                  SupportsShouldProcess=$true, 
                  ConfirmImpact='Medium')]
    PARAM(
        # Candidate face ids. The maximum is 100 faces
        [Parameter(Mandatory=$true, 
                   ValueFromPipeline=$false,
                   ValueFromPipelineByPropertyName=$false, 
                   ValueFromRemainingArguments=$false, 
                   Position=0)]
        [ValidateNotNullOrEmpty()]
        [string[]]$faceIds,
        # API Key required to post to oxford project 
        [Parameter(Mandatory=$true, 
                   ValueFromPipeline=$false,
                   ValueFromPipelineByPropertyName=$false, 
                   ValueFromRemainingArguments=$false, 
                   Position=1)]
        [ValidateNotNullOrEmpty()]
        [string]$apiKey
        )

    BEGIN
    {
        $body = @{
            'faceIds' = $faceIds
        } | ConvertTo-Json
        $header = @{}
        $header.Add('Ocp-Apim-Subscription-Key', $ApiKey)
        $URI = 'https://api.projectoxford.ai/face/v0/groupings'
    }#end BEGIN

    PROCESS
    {
        try
        {
            $group = Invoke-WebRequest -Method Post -Uri $URI -Headers $header -Body $body -ContentType application/json -EA Stop
            $results = $group.Content | ConvertFrom-Json -EA Stop
        }
        catch
        {
            write-error $_ -EA Stop
        }
    }#end PROCESS

    END
    {
        $results
    }#end END

}#end Get-FaceGrouping
Export-ModuleMember -Function Get-FaceGrouping

function Get-FaceIdentification
{
<#
.Synopsis
   Identifies persons from a person group by one or more input faces. 
.DESCRIPTION
   To recognize which person a face belongs to, Face Identification needs a 
   person group that contains number of persons. Each person contains one or
   more faces. After a person group prepared, it should be trained to make 
   it ready for identification. Then the identification API compares the input
   face to those persons' faces in person group and returns the best-matched 
   candidate persons, ranked by confidence. 
.EXAMPLE
   Get-FaceIdentification -faceIds $FaceIDs `
     -personGroupId $PersonGroupId -ApiKey '123456789abcdefg'
.NOTES
   Created By George Rolston 9/25/2015
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
        # Array of face's Ids to query. The maximum number of face Ids is 10. 
        [Parameter(Mandatory=$true, 
                   ValueFromPipeline=$false,
                   ValueFromPipelineByPropertyName=$true, 
                   ValueFromRemainingArguments=$false, 
                   Position=1)]
        [ValidateNotNullOrEmpty()]
        [ValidateScript( { $_.Count -LE 10 } ) ]
        [string[]]$faceIds,
        # The max number of candidates to return
        [Parameter(Mandatory=$false, 
                   ValueFromPipeline=$false,
                   ValueFromPipelineByPropertyName=$false, 
                   ValueFromRemainingArguments=$false, 
                   Position=2)]
        [ValidateRange(1,5)]
        [int]$maxNumOfCandidatesReturned = 1,
        # The target person's belonging person group's ID. 
        [Parameter(Mandatory=$true, 
                   ValueFromPipeline=$false,
                   ValueFromPipelineByPropertyName=$false, 
                   ValueFromRemainingArguments=$false, 
                   Position=3)]
        [ValidateNotNullOrEmpty()]
        [int]$personGroupId
    )

    BEGIN
    {
        $body = @{
            'faceIds' = $faceIds
            'personGroupId' = $personGroupId
            'maxNumOfCandidatesReturned' = $maxNumOfCandidatesReturned
        } | ConvertTo-Json
        $header = @{}
        $header.Add('Ocp-Apim-Subscription-Key', $ApiKey)
        $URI = 'https://api.projectoxford.ai/face/v0/identifications '
    }#end BEGIN

    PROCESS
    {
        try
        {
            $identify = Invoke-WebRequest -Method Post -Uri $URI -Headers $header -Body $body -ContentType application/json -EA Stop
            $results = $identify.Content | ConvertFrom-Json -EA Stop
        }
        catch
        {
            write-error $_ -EA Stop
        }
    }#end PROCESS

    END
    {
        $results
    }#end END

}#end Get-FaceIdentification
Export-ModuleMember -Function Get-FaceIdentification

function Get-FaceVerification
{
<#
.Synopsis
   Analyzes two faces and determine whether they are from the same person.  
.DESCRIPTION
   Verification works well for frontal and near-frontal faces. For the 
   scenarios that are sensitive to accuracy please use with own judgment.
.EXAMPLE
   Get-FaceVerification -faceId1 $FaceID1 -faceId2 $FaceID2
.NOTES
   Created By George Rolston 9/25/2015
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
        # Face 1 in verification face-pair. 
        [Parameter(Mandatory=$true,
                   ValueFromPipeline=$false,
                   ValueFromPipelineByPropertyName=$false, 
                   ValueFromRemainingArguments=$false, 
                   Position=1)]
        [ValidateNotNullOrEmpty()]
        [string]$faceId1,
        # Face 2 in verification face-pair . 
        [Parameter(Mandatory=$true,
                   ValueFromPipeline=$false,
                   ValueFromPipelineByPropertyName=$true, 
                   ValueFromRemainingArguments=$false, 
                   Position=2)]
        [ValidateNotNullOrEmpty()]
        [string]$faceId2
    )

    BEGIN
    {
        $body = @{
            'faceId1' = $faceId1
            'faceId2' = $faceId2
        } | ConvertTo-Json
        $header = @{}
        $header.Add('Ocp-Apim-Subscription-Key', $ApiKey)
        $URI = 'https://api.projectoxford.ai/face/v0/verifications'
    }#end BEGIN

    PROCESS
    {
        try
        {
            $Verifcation = Invoke-WebRequest -Method Post -Uri $URI -Headers $header -Body $body -ContentType application/json -EA Stop
            $results = $Verifcation.Content | ConvertFrom-Json -EA Stop
        }
        catch
        {
            write-error $_ -EA Stop
        }
    }#end PROCESS

    END
    {
        $results
    }#end END
}#end Get-FaceVerification
Export-ModuleMember -Function Get-FaceVerification

function Get-Person
{
<#
.Synopsis
   Retrieves a person's information, including registered faces, name and userData.  
.DESCRIPTION
   Retrieves a person's information, including registered faces, name and userData. 
.EXAMPLE
   Get-Person -personId '123-456-abc' -personGroupId 1
.NOTES
   Created By George Rolston 9/25/2015
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
        # Person ID to retrieve. 
        [Parameter(Mandatory=$true, 
                   ValueFromPipeline=$true,
                   ValueFromPipelineByPropertyName=$true, 
                   ValueFromRemainingArguments=$false, 
                   Position=1)]
        [ValidateNotNullOrEmpty()]
        [string]$personId,
        # personGroupID to look for person. 
        [Parameter(Mandatory=$true, 
                   ValueFromPipeline=$false,
                   ValueFromPipelineByPropertyName=$false, 
                   ValueFromRemainingArguments=$false, 
                   Position=2)]
        [ValidateNotNullOrEmpty()]
        [int]$personGroupId
        )
    BEGIN{
        $header = @{}
        $header.Add('Ocp-Apim-Subscription-Key', $apiKey)
    }#end BEGIN
    PROCESS{
        $uri = 'https://api.projectoxford.ai/face/v0/persongroups/'+ $personGroupId +'/persons/' + $personId
        try
        {
            $results = Invoke-WebRequest -Method Get -Uri $uri -Headers $header -ContentType application/json -EA Stop3
            $obj = $results.content | ConvertFrom-Json
        }
        catch
        {
            Write-error $_ -EA Stop
        }
    }#end PROCESS
    END{
        $obj
    }#end END
}#end Get-Person
Export-ModuleMember -Function Get-Person

function Get-PersonGroup
{
<#
.Synopsis
  Get persongroup(s) details. 
.DESCRIPTION
   Get all or specific persongroup under an API key.
.EXAMPLE
   Get specific PersonGroup by ID
   Get-PersonGroup -personGroupId 1 -ApiKey '123456789abcdefg'
.EXAMPLE
   List all PersonGroups for API
   Get-PersonGroup -ApiKey '123456789abcdefg'
.NOTES
   Created By George Rolston 9/5/2015
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
        # personGroupID if specific personGroup to be retrieved. 
        [Parameter(Mandatory=$false, 
                   ValueFromPipeline=$false,
                   ValueFromPipelineByPropertyName=$false, 
                   ValueFromRemainingArguments=$false, 
                   Position=1)]
        [int]$personGroupId
        )
    BEGIN{
        $header = @{}
        $header.Add('Ocp-Apim-Subscription-Key', $apiKey)
    }#end BEGIN
    PROCESS{
        if($personGroupId)
        {
            $uri = 'https://api.projectoxford.ai/face/v0/persongroups/'+ $personGroupId 
        }
        else
        {
            $uri = 'https://api.projectoxford.ai/face/v0/persongroups/'
        }
        try
        {
            $results = Invoke-WebRequest -Method Get -Uri $uri -Headers $header -ContentType application/json -EA Stop
            $obj = $results.content | ConvertFrom-Json
        }
        catch
        {
            Write-error $_ -EA Stop
        }
    }#end PROCESS
    END{
        $obj
    }#end END
}#end Get-PersonGroup
Export-ModuleMember -Function Get-PersonGroup

function Get-PersonGroupMembers
{
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
        # Person Group ID to retrieve persons 
        [Parameter(Mandatory=$true, 
                   ValueFromPipeline=$true,
                   ValueFromPipelineByPropertyName=$true, 
                   ValueFromRemainingArguments=$false, 
                   Position=1)]
        [ValidateNotNullOrEmpty()]
        [int]$personGroupId
        )
    BEGIN{
        $header = @{}
        $header.Add('Ocp-Apim-Subscription-Key', $apiKey)
    }#end BEGIN
    PROCESS{
        $uri = 'https://api.projectoxford.ai/face/v0/persongroups/'+ $personGroupId + '/persons'
        try
        {
            $results = Invoke-WebRequest -Method Get -Uri $uri -Headers $header -ContentType application/json -EA Stop
            $obj = $results.content | ConvertFrom-Json
        }
        catch
        {
            Write-error $_ -EA Stop
        }
    }#end PROCESS
    END{
        return $obj
    }#end END
}#end Get-PersonGroupMembers
Export-ModuleMember -Function Get-PersonGroupMembers

function Get-PersonFace
{
<#
.Synopsis
   Retrieves a face's information, such as the userData.   
.DESCRIPTION
   Retrieves a face's information, such as the userData.  
.EXAMPLE
   Get-PersonFace -faceId '123-456-cde' -personId '123-456-abc' -personGroupId 1 -apiKey '123456789'
.NOTES
   Created By George Rolston 9/25/2015
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
        # The target faceId. 
        [Parameter(Mandatory=$true, 
                   ValueFromPipeline=$true,
                   ValueFromPipelineByPropertyName=$true, 
                   ValueFromRemainingArguments=$false, 
                   Position=1)]
        [ValidateNotNullOrEmpty()]
        [string]$faceId,
        # The target personId the face belongs to. 
        [Parameter(Mandatory=$false, 
                   ValueFromPipeline=$true,
                   ValueFromPipelineByPropertyName=$true, 
                   ValueFromRemainingArguments=$false, 
                   Position=2)]
        [ValidateNotNullOrEmpty()]
        [string]$personId,
        # The target person's belonging person group's ID. 
        [Parameter(Mandatory=$true, 
                   ValueFromPipeline=$false,
                   ValueFromPipelineByPropertyName=$false, 
                   ValueFromRemainingArguments=$false, 
                   Position=3)]
        [ValidateNotNullOrEmpty()]
        [int]$personGroupId
        )
    BEGIN{
        $header = @{}
        $header.Add('Ocp-Apim-Subscription-Key', $apiKey)
    }#end BEGIN
    PROCESS{
        $uri = 'https://api.projectoxford.ai/face/v0/persongroups/'+ $personGroupId +'/persons/' + $personId + '/faces/' + $faceId
        try
        {
            $results = Invoke-WebRequest -Method Get -Uri $uri -Headers $header -ContentType application/json -EA Stop3
            $obj = $results.content | ConvertFrom-Json
        }
        catch
        {
            Write-error $_ -EA Stop
        }
    }#end PROCESS
    END{
        $obj
    }#end END
    
}#end Get-PersonFace
Export-ModuleMember -Function Get-PersonFace

function Get-SimilarFace 
{
<#
.Synopsis
   Finds similar-looking faces of a specified face from a list of candidate faces.
.DESCRIPTION
   With a query face and a candidate face list it returns similar faces 
   list ranked by similarity. The candidate face list has a limit of 100 faces.  
.EXAMPLE
   Get-SimilarFace  -apiKey '123456789abcdefg' -faceId '1323-13223-133' -faceIds $faceIds
.NOTES
   Created By George Rolston 9/5/2015
#>
    [CmdletBinding( 
                  SupportsShouldProcess=$true, 
                  ConfirmImpact='Medium')]
    PARAM(
        # Source face for the similar faces. The faceId is from the Detection API. 
        [Parameter(Mandatory=$true, 
                   ValueFromPipeline=$true,
                   ValueFromPipelineByPropertyName=$true, 
                   ValueFromRemainingArguments=$false, 
                   Position=0)]
        [ValidateNotNullOrEmpty()]
        [string]$faceId,
        # Candidate face ids. The maximum is 100 faces
        [Parameter(Mandatory=$true, 
                   ValueFromPipeline=$false,
                   ValueFromPipelineByPropertyName=$false, 
                   ValueFromRemainingArguments=$false, 
                   Position=1)]
        [ValidateNotNullOrEmpty()]
        [string[]]$faceIds,
        # API Key required to post to oxford project 
        [Parameter(Mandatory=$true, 
                   ValueFromPipeline=$false,
                   ValueFromPipelineByPropertyName=$false, 
                   ValueFromRemainingArguments=$false, 
                   Position=2)]
        [ValidateNotNullOrEmpty()]
        [string]$apiKey
        )
    BEGIN
    {
        $body = @{
            'faceId' = $faceId
            'faceIds' = $faceIds
        } | ConvertTo-Json
        $header = @{}
        $header.Add('Ocp-Apim-Subscription-Key', $ApiKey)
        $URI = 'https://api.projectoxford.ai/face/v0/findsimilars'
    }#end BEGIN

    PROCESS
    {
        try
        {
            $find = Invoke-WebRequest -Method Post -Uri $URI -Headers $header -Body $body -ContentType application/json -EA Stop
            $results = $find.Content | ConvertFrom-Json -EA Stop
        }
        catch
        {
            write-error $_ -EA Stop
        }
    }#end PROCESS

    END
    {
        $results
    }#end END
}#end Get-SimilarFace
Export-ModuleMember -Function Get-SimilarFace 

function Get-TrainingStatus
{
<#
.Synopsis
   Retrieves the training status of a person group.
.DESCRIPTION
   Retrieves the training status of a person group. 
   Training is triggered by the Train PersonGroup API. 
   The training will process for a while on the server side. 
   This API can query whether the training is completed or ongoing. 
.EXAMPLE
   Get-TrainingStatus -personGroupID 1 -ApiKey '123456789abcdefg'
.NOTES
   Created By George Rolston 9/26/2015
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
        # The id of target person group.  
        [Parameter(Mandatory=$true, 
                   ValueFromPipeline=$true,
                   ValueFromPipelineByPropertyName=$false, 
                   ValueFromRemainingArguments=$false, 
                   Position=1)]
        [int]$personGroupId
        )
    BEGIN{
        $header = @{}
        $header.Add('Ocp-Apim-Subscription-Key', $apiKey)
    }#end BEGIN
    PROCESS{
        $uri = 'https://api.projectoxford.ai/face/v0/persongroups/'+ $personGroupId + '/training'
        try
        {
            $results = Invoke-WebRequest -Method Get -Uri $uri -Headers $header -ContentType application/json -EA Stop
            $obj = $results.content | ConvertFrom-Json
        }
        catch
        {
            Write-error $_ -EA Stop
        }
    }#end PROCESS
    END{
        $obj
    }#end END  
}#end Get-TrainingStatus
Export-ModuleMember -Function Get-TrainingStatus

function Start-PersonGroupTraining
{
<#
.Synopsis
  Starts a person group training. 
.DESCRIPTION
   Training is a necessary preparation process of a person group before identification. 
   Each person group needs to be trained in order to call Identification. The training 
   will process for a while on the server side even after this API has responded. 
   You can query the training status by Get-TrainingStatus function 
.EXAMPLE
   Start-PersonGroupTraining -personGroupId 1 -ApiKey '123456789abcdefg'
.NOTES
   Created By George Rolston 9/5/2015
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
        # List of image file paths to load. 
        [Parameter(Mandatory=$true, 
                   ValueFromPipeline=$false,
                   ValueFromPipelineByPropertyName=$false, 
                   ValueFromRemainingArguments=$false, 
                   Position=1)]
        [int]$personGroupId
        )
    BEGIN{
        $header = @{}
        $header.Add('Ocp-Apim-Subscription-Key', $apiKey)
    }#end BEGIN
    PROCESS
    {
        $uri = 'https://api.projectoxford.ai/face/v0/persongroups/'+ $personGroupId + '/training'
        try
        {
            $results = Invoke-WebRequest -Method Post -Uri $uri -Headers $header -ContentType application/json -EA Stop
            $obj = $results.content | ConvertFrom-Json
        }
        catch
        {
            Write-error $_ -EA Stop
        }
    }#end PROCESS
    END{
        $obj
    }#end END

}#end Start-PersonGroupTraining
Export-ModuleMember -Function Start-PersonGroupTraining

function Update-Person
{
<#
.Synopsis
   Update a Person to Oxford API Database
.DESCRIPTION
   Add a person along with Face Ids and Description to person group.
   Only 1000 Persons are able to be created under the free API account.
   Each person can have 32 images to be stored for training. 
.EXAMPLE
   Update-Person -apiKey $ApiKey -personGroupId 1 -personName 'CJ' `
     -faceIDs $faceIDs -Description 'Test Person Added'
.EXAMPLE
   Update-Person -apiKey $ApiKey -personGroupId 1 -personName 'CJ'
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
        [string]$name,
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
                  "name" = $name
                  "userData" = $Description
                  "faceIds" = $faceIDs
                  } | ConvertTo-Json
        $header = @{}
        $header.Add('Ocp-Apim-Subscription-Key', $ApiKey)
        $uri = 'https://api.projectoxford.ai/face/v0/persongroups/' + $personGroupId +'/persons' 
        try
        {
            $Post = Invoke-WebRequest -Method Patch -Uri $uri -Headers $header -ContentType application/json -ErrorAction Stop -Body $Body
            $results = $Post.Content | ConvertFrom-Json
        }
        catch
        {
            Write-Error $_ -EA Stop
        }
    }#end PROCESS
    END
    {
        $results
    }#end END
}#end Update-Person
Export-ModuleMember -Function Update-Person

function Update-PersonFace
{
<#
.Synopsis
   Adds a face to a person for identification
.DESCRIPTION
   Adds a face to a person for identification. The maximum face count for each 
   person is 32. The face ID must be added to a person before its expiration. 
   Typically a face ID expires 24 hours after detection. 
.EXAMPLE
   Add-Face -ApiKey '123456789abcdefg' -faceId '123-1231-12232'  ` 
     -personId '123-452zaz-a123' -personGroupId 1 -faceDescription 'Test Face'
.NOTES
   Created By George Rolston 9/25/2015
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
        # The target faceId. 
        [Parameter(Mandatory=$true, 
                   ValueFromPipeline=$true,
                   ValueFromPipelineByPropertyName=$true, 
                   ValueFromRemainingArguments=$false, 
                   Position=1)]
        [ValidateNotNullOrEmpty()]
        [string]$faceId,
        # The target personId the face belongs to. 
        [Parameter(Mandatory=$true, 
                   ValueFromPipeline=$true,
                   ValueFromPipelineByPropertyName=$false, 
                   ValueFromRemainingArguments=$false, 
                   Position=2)]
        [ValidateNotNullOrEmpty()]
        [string]$personId,
        # The target person's belonging person group's ID. 
        [Parameter(Mandatory=$true, 
                   ValueFromPipeline=$false,
                   ValueFromPipelineByPropertyName=$false, 
                   ValueFromRemainingArguments=$false, 
                   Position=3)]
        [ValidateNotNullOrEmpty()]
        [int]$personGroupId,
        # user data to describe the face. 
        [Parameter(Mandatory=$true, 
                   ValueFromPipeline=$false,
                   ValueFromPipelineByPropertyName=$false, 
                   ValueFromRemainingArguments=$false, 
                   Position=4)]
        [ValidateNotNullOrEmpty()]
        [Alias("userData")]
        [string]$faceDescription
        )

    BEGIN
    {
        $body = @{
            'userData' = $faceDescription
        } | ConvertTo-JSON
        $header = @{}
        $header.Add('Ocp-Apim-Subscription-Key', $apiKey)
    }

    PROCESS
    {
        $uri = 'https://api.projectoxford.ai/face/v0/persongroups/'+ $personGroupId +'/persons/' + $personId + '/faces/' + $faceId
        try
        {
            $results = Invoke-WebRequest -Method Patch -Uri $uri -Body $body -Headers $header -ContentType application/json -EA Stop
            $obj = $results.content | ConvertFrom-Json
        }
        catch
        {
            Write-error $_ -EA Stop
        }
    }#end PROCESS

    END
    {
        $obj
    }#end END

}#end Update-PersonFace
Export-ModuleMember -Function Update-PersonFace

function Update-PersonGroup
{
<#
.Synopsis
  Update a Person Group 
.DESCRIPTION
   Create a PersonGroup to add Persons to. A persongroup
   is required before you can add a Person to the 
   Oxford API database.
.EXAMPLE
   Update-PersonGroup -GroupName 'Admin Group'  `
     -Description 'The person group who are administrators' -ApiKey '123456789abcdefg'
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
        [Alias("userData")]
        [string]$Description = "Person Group created on $(Get-Date -Format "MM/dd/yyyy HH:mm")",
        # API Key required to post to oxford project 
        [Parameter(Mandatory=$true, 
                   ValueFromPipeline=$false,
                   ValueFromPipelineByPropertyName=$false, 
                   ValueFromRemainingArguments=$false, 
                   Position=2)]
        [ValidateNotNullOrEmpty()]
        [string]$apiKey
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
            $Post = Invoke-WebRequest -Method Patch -Uri $uri -Headers $header -ContentType application/json -ErrorAction Stop -Body $Body
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
}#end Update-PersonGroup
Export-ModuleMember -Function Update-PersonGroup