using namespace System.Net
function Json($data, $statusCode = [System.Net.HttpStatusCode]::OK) {
    $contentType = "application/json"
    $json = ConvertTo-Json $data
    return $json, $statusCode, $contentType
}