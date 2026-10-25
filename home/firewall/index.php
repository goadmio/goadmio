<html>
<head>
    <title>Access Denied</title>
    <style>
        body {
            background-color: #000000;
            color: #ffffff;
            font-family: 'Arial', sans-serif;
            margin: 0;
            padding: 0;
            display: flex;
            justify-content: center;
            align-items: center;
            min-height: 100vh;
            text-align: center;
        }
        
        .container {
            max-width: 600px;
            padding: 40px 20px;
            border: 1px solid #333333;
            border-radius: 8px;
            background-color: #000000;
            box-shadow: 0 0 20px rgba(255,255,255,0.05);
        }
        
        h1 {
            color: #ffffff;
            font-family: 'Arial', sans-serif;
            font-size: 32px;
            margin-bottom: 20px;
            font-weight: 400;
            letter-spacing: 1px;
            border-bottom: 1px solid #333333;
            padding-bottom: 15px;
        }
        
        .ip-container {
            display: flex;
            align-items: center;
            justify-content: center;
            gap: 10px;
            margin: 15px 0;
        }
        
        strong {
            color: #ffffff;
            font-family: 'Arial', sans-serif;
            font-weight: 600;
            background-color: #000000;
            padding: 8px 15px;
            border-radius: 4px;
            font-size: 18px;
            border: 1px solid #333333;
        }
        
        .copy-btn {
            background: #000000;
            border: 1px solid #333333;
            cursor: pointer;
            padding: 8px;
            display: inline-flex;
            align-items: center;
            justify-content: center;
            color: #888888;
            transition: color 0.3s ease;
            border-radius: 4px;
        }
        
        .copy-btn:hover {
            color: #ffffff;
            border-color: #666666;
        }
        
        .copy-btn svg {
            width: 20px;
            height: 20px;
        }
        
        .copy-btn.copied svg {
            color: #4CAF50;
        }
        
        .tooltip {
            position: relative;
            display: inline-block;
        }
        
        .tooltip .tooltiptext {
            visibility: hidden;
            width: 80px;
            background-color: #000000;
            color: #fff;
            font-family: 'Arial', sans-serif;
            text-align: center;
            border-radius: 4px;
            padding: 5px;
            position: absolute;
            z-index: 1;
            bottom: 125%;
            left: 50%;
            margin-left: -40px;
            opacity: 0;
            transition: opacity 0.3s;
            font-size: 12px;
            border: 1px solid #333333;
        }
        
        .tooltip:hover .tooltiptext {
            visibility: visible;
            opacity: 1;
        }
        
        p {
            color: #cccccc;
            font-family: 'Arial', sans-serif;
            line-height: 1.6;
            font-size: 16px;
            margin: 20px 0;
        }
        
        hr {
            border: none;
            border-top: 1px solid #333333;
            margin: 30px 0 20px 0;
        }
        
        .footer {
            font-size: 12px;
            color: Silver;
            margin-top: 20px;
            font-family: 'Arial', sans-serif;
        }
        
        .footer a {
            color: Silver;
            text-decoration: none;
            transition: color 0.3s ease;
            font-family: 'Arial', sans-serif;
        }
        
        .footer a:hover {
            color: #ffffff;
            text-decoration: underline;
        }

        .ip-address p {
            font-family: 'Arial', sans-serif;
        }
    </style>
</head>
<body>
    <div class="container">
        <h1>Access Denied</h1>
        
        <div class="ip-address">
            <p>Your IP address</p>
            <div class="ip-container">
                <strong id="ipAddress">
                    
                <?php
                include "/usr/local/goadmio/home/go/include/function/function.php";
                $IP = ClientIP();
                echo "$IP";
                ?>
                
                </strong>
                
                <div class="tooltip">
                    <button class="copy-btn" onclick="copyIP()" id="copyButton">
                        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                            <rect x="9" y="9" width="13" height="13" rx="2" ry="2"></rect>
                            <path d="M5 15H4a2 2 0 0 1-2-2V4a2 2 0 0 1 2-2h9a2 2 0 0 1 2 2v1"></path>
                        </svg>
                    </button>
                    <span class="tooltiptext" id="tooltip">Copy</span>
                </div>
            </div>
            <p>has been blocked from accessing this website.</p>
        </div>
        
        <p>If you believe this is an error, please contact the administrator.</p>
        
        <hr>
        
        <div class="footer">
            Powered by <a href="https://gopanel.org" target="_blank">GoAdmio</a>
        </div>
    </div>

    <script>
        function copyIP() {
            var ipElement = document.getElementById("ipAddress");
            var ipText = ipElement.innerText || ipElement.textContent;
            
            navigator.clipboard.writeText(ipText).then(function() {
                var tooltip = document.getElementById("tooltip");
                var copyBtn = document.getElementById("copyButton");
                
                tooltip.innerHTML = "Copied!";
                copyBtn.classList.add("copied");
                
                setTimeout(function() {
                    tooltip.innerHTML = "Copy";
                    copyBtn.classList.remove("copied");
                }, 2000);
            }, function(err) {
                console.error('Could not copy text: ', err);
                var tooltip = document.getElementById("tooltip");
                tooltip.innerHTML = "Error!";
                
                setTimeout(function() {
                    tooltip.innerHTML = "Copy";
                }, 2000);
            });
        }
    </script>
</body>
</html>