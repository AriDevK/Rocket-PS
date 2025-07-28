using namespace System.Net
function Xml($data, $statusCode = [System.Net.HttpStatusCode]::OK) {
    $contentType = "application/xml"
    $data = [PSCustomObject]$data
    $xml = $data | ConvertTo-Xml -NoTypeInformation
    return $xml.OuterXml , $statusCode, $contentType
}