#!/usr/local/bin/pwsh
<#
        MIT License

        Copyright (c) 2018 ytmknd

        Permission is hereby granted, free of charge, to any person obtaining a copy
        of this software and associated documentation files (the "Software"), to deal
        in the Software without restriction, including without limitation the rights
        to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
        copies of the Software, and to permit persons to whom the Software is
        furnished to do so, subject to the following conditions:

        The above copyright notice and this permission notice shall be included in all
        copies or substantial portions of the Software.

        THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
        IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
        FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
        AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
        LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
        OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
        SOFTWARE.

Ussage:

#>

$DebugPreference = "Continue"

<#
    opcode  operation
      1     Read request (RRQ)
      2     Write request (WRQ)
      3     Data (DATA)
      4     Acknowledgment (ACK)
      5     Error (ERROR)
#>
set-variable -name OP_RRQ   -value 1 -option constant
set-variable -name OP_WRQ   -value 2 -option constant
set-variable -name OP_DATA  -value 3 -option constant
set-variable -name OP_ACK   -value 4 -option constant
set-variable -name OP_ERROR -value 5 -option constant

$Global:endpointIPAddress = "0.0.0.0"
$Global:endpointPort = 0
$Global:content = ([byte[]] (@(0) * 512))

function handleRRQ() {
    #$dist = new-object System.Net.IPEndPoint (([system.net.IPAddress]::Parse($endpointIPAddress)), $endpointPort)
    $udpclient = new-Object System.Net.Sockets.UdpClient($endpointIPAddress, $endpointPort)

    $contentSnd = ([byte[]] (@(0) * (2 + 2 + 1)))
    # parse request


    while(1) {
        # send test
        $contentSnd[0] = [byte]0
        $contentSnd[1] = [byte]3
        $contentSnd[2] = [byte]0
        $contentSnd[3] = [byte]1
        $contentSnd[4] = 65
        Write-Debug("Send")
        $udpclient.Send($contentSnd,$contentSnd.Length)

        # wait ack
        $endpointcl = new-object System.Net.IPEndPoint ([IPAddress]::Any, 0)
        $contentSnd = $udpclient.Receive([ref]$endpointcl)
        #Write-Debug($contentSnd)

        break
    }
}

function handleWRQ() {

}

function getOpcode(){
    $bytes = ([byte[]] (@( $content[1], $content[0], 00, 00 )))
    $op = [BitConverter]::ToInt32($bytes, 0)
    return $op
}

function mainloop() {
    $port=69
    $endpoint = new-object System.Net.IPEndPoint ([IPAddress]::Any, 0)
    $udpclientServ = new-Object System.Net.Sockets.UdpClient $port

    while(1) {
        $content = $udpclientServ.Receive([ref] $endpoint)
        Set-Variable -Name "endpointIPAddress" -Scope global -Value $endpoint.Address #.ToString()
        Set-Variable -Name "endpointPort" -Scope global -Value $endpoint.Port     
        Write-Debug ("endpointIPAddress:$($endpointIPAddress):$($endpointPort)") 

        echo ("I recieved a TFTP packet")
        switch(getOpcode($content)) {
            $OP_RRQ { 
                Write-Debug ("-->Recieved RRQ")
                handleRRQ
                }
            $OP_WRQ {
                Write-Debug ("-->Recieved WRQ")
                }
            $OP_DATA { 
                Write-Debug ("-->Recieved DATA")
                }
            $OP_ACK {
                Write-Debug ("-->Recieved ACK")
                break
            }
            $OP_ERROR {
                Write-Debug ("-->Recieved ERROR")
            }
            default { 
                Write-Debug ("Recieved unknown message.")
                Write-Debug ("-->Do nothing.") 
            }
        }
        Write-Debug ("--") 
        break #debug
    }

}

mainloop
#$content =  ([byte[]] (@(0,1,0,0)))
#Write-Debug (getOpcode)
