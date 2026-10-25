<?php

include_once "vendor/autoload.php";

use PHPMailer\PHPMailer\PHPMailer;
use PHPMailer\PHPMailer\Exception;

function SendMail($To,$Subject,$Message,$SenderName="",$From="",$ReplyTo="",$CopyToSent=0,$File="",$AsHTML=-1,$Auth=1,$Verify=0,$Charset="UTF-8")
{
	global $SMTPHost,$SMTPPort,$SMTPUser,$SMTPPass;
	global $AlternativeSMTPHost,$AlternativeSMTPPort,$AlternativeSMTPUser,$AlternativeSMTPPass;
	global $Alternative;
	
	
	$mail = new PHPMailer(true);                              // Passing `true` enables exceptions
	try 
	{
		//Server settings
		//$mail->SMTPDebug = 2;                                 // Enable verbose debug output
		$mail->isSMTP();                                      // Set mailer to use SMTP
		$mail->CharSet = $Charset;

		$mail->Host = $SMTPHost;               
		
		if ($Auth==1)
		{
		$mail->SMTPAuth = true;
		}
		
		$mail->Username = $SMTPUser;
		$mail->Password = $SMTPPass;                           // SMTP password
		
		if ($SMTPPort=="465")
		{
		$mail->SMTPSecure = 'ssl';
		}
		
		$mail->Port = $SMTPPort;
		
		if ($From=="")
		{
		$mail->setFrom($SMTPUser, $SenderName);
		}
		else
		{
		$mail->setFrom($From, $SenderName);
		}
		
		$mail->addAddress($To);

		if ($ReplyTo!="")
		{
		$mail->addReplyTo($ReplyTo);
		}
		
		// $mail->AddCustomHeader("List-Unsubscribe: <https://crm.mls.eg/unsubscribe.php?Email=$To>");
		//$mail->addCC('cc@example.com');
		//$mail->addBCC('bcc@example.com');


		//$mail->addAttachment('/var/tmp/file.tar.gz');         // Add attachments
		//$mail->addAttachment('/tmp/image.jpg', 'new.jpg');    // Optional name

		if ($File!="")
		{
		
			if (stristr($File,","))
			{
				$Files=explode(",",$File);
				foreach ($Files as &$File) 
				{
					$mail->addAttachment($File);
				}
				
			}
			else
			{
			$mail->addAttachment($File);
			}
		
		}
		
		if ($AsHTML==-1)
		{
			if (stristr($Message,"<") AND stristr($Message,">"))
			{
			$AsHTML=1;
			}
			else
			{
			$AsHTML=0;
			}
		}

		if ($AsHTML==1)
		{
		$mail->isHTML(true);                                  // Set email format to HTML
		}
		
		$mail->Subject = $Subject;
		$mail->Body    = $Message;
		
		
		//$mail->AltBody = 'This is the body in plain text for non-HTML mail clients';

		if ($Verify==0)
		{
		$mail->SMTPOptions = array('ssl' => array('verify_peer' => false,'verify_peer_name' => false,'allow_self_signed' => true));
		}

		$mail->send();	
		if ($CopyToSent==1) 
		{
			$IMAPHost=str_replace("ssl://","",$SMTPHost);

			$IMAPHost = "{".$SMTPHost.":143/novalidate-cert}Sent";
			$ImapStream = imap_open($IMAPHost, $SMTPUser, $SMTPPass);
			$Result = imap_append($ImapStream, $IMAPHost, $mail->getSentMIMEMessage());
			imap_close($ImapStream);
		}
		
		if ($Alternative!=1)
		{
		return "Message successfully sent";
		}
		
	} 
	catch (Exception $e) 
	{

		if ($AlternativeSMTPHost=="")
		{
		return $mail->ErrorInfo;
		}
		else
		{
		$Alternative=1;
		}

	}
	
	

	if ($Alternative==1)
	{

		$SMTPHost=$AlternativeSMTPHost;
		$SMTPPort=$AlternativeSMTPPort;
		$SMTPUser=$AlternativeSMTPUser;
		$SMTPPass=$AlternativeSMTPPass;

		$mail = new PHPMailer(true);                              // Passing `true` enables exceptions
		try 
		{
			//Server settings
			//$mail->SMTPDebug = 2;                                 // Enable verbose debug output
			$mail->isSMTP();                                      // Set mailer to use SMTP
			$mail->CharSet = $Charset;

			$mail->Host = $SMTPHost;               
			
			if ($Auth==1)
			{
			$mail->SMTPAuth = true;
			}
			
			$mail->Username = $SMTPUser;
			$mail->Password = $SMTPPass;                           // SMTP password
			
			if ($SMTPPort=="465")
			{
			$mail->SMTPSecure = 'ssl';
			}
			
			$mail->Port = $SMTPPort;
			
			if ($From=="")
			{
			$mail->setFrom($SMTPUser, $SenderName);
			}
			else
			{
			$mail->setFrom($From, $SenderName);
			}
			
			$mail->addAddress($To);

			if ($ReplyTo!="")
			{
			$mail->addReplyTo($ReplyTo);
			}
			
			$mail->AddCustomHeader("List-Unsubscribe: <https://crm.mls.eg/unsubscribe.php?Email=$To>");

			
			//$mail->addCC('cc@example.com');
			//$mail->addBCC('bcc@example.com');


			//$mail->addAttachment('/var/tmp/file.tar.gz');         // Add attachments
			//$mail->addAttachment('/tmp/image.jpg', 'new.jpg');    // Optional name

			if ($File!="")
			{
			
				if (stristr($File,","))
				{
					$Files=explode(",",$File);
					foreach ($Files as &$File) 
					{
						$mail->addAttachment($File);
					}
					
				}
				else
				{
				$mail->addAttachment($File);
				}
			
			}
			
			if ($AsHTML==-1)
			{
				if (stristr($Message,"<") AND stristr($Message,">"))
				{
				$AsHTML=1;
				}
				else
				{
				$AsHTML=0;
				}
			}

			if ($AsHTML==1)
			{
			$mail->isHTML(true);                                  // Set email format to HTML
			}
			
			$mail->Subject = $Subject;
			$mail->Body    = $Message;
			
			
			//$mail->AltBody = 'This is the body in plain text for non-HTML mail clients';

			if ($Verify==0)
			{
			$mail->SMTPOptions = array('ssl' => array('verify_peer' => false,'verify_peer_name' => false,'allow_self_signed' => true));
			}

			$mail->send();	
			if ($CopyToSent==1) 
			{
				$IMAPHost=str_replace("ssl://","",$SMTPHost);

				$IMAPHost = "{".$SMTPHost.":143/novalidate-cert}Sent";
				$ImapStream = imap_open($IMAPHost, $SMTPUser, $SMTPPass);
				$Result = imap_append($ImapStream, $IMAPHost, $mail->getSentMIMEMessage());
				imap_close($ImapStream);
			}
			
			return "Message successfully sent";
			
		} 
		catch (Exception $e) 
		{
			return $mail->ErrorInfo;
		}

	}
	
}

?>