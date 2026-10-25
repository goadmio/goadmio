<?php

function ResizeImage($ImageFilePath, $NewImageFilePath, $MaxWidth=480, $MaxHeight=1600 )
{
// المحافظة على ابعاد الصورة مع عدم القص منها
	global $FullImageWidth,$FullImageHeight;
	$Ext=strtolower (substr("$ImageFilePath", -4));
	$ReturnVal = 1;
	if ($Ext=="jpeg" or $Ext==".jpg")
	{
		$ReturnVal = ( ($img = ImageCreateFromJPEG ( $ImageFilePath )) && $ReturnVal == 1 ) ? "1" : "0";
	}

	if ($Ext==".gif")
	{
		$ReturnVal = ( ($img = ImageCreateFromGIF ( $ImageFilePath )) && $ReturnVal == 1 ) ? "1" : "0";
	}

	if ($Ext==".png")
	{
		$ReturnVal = ( ($img = ImageCreateFromPNG ( $ImageFilePath )) && $ReturnVal == 1 ) ? "1" : "0";
	}

	$FullImageWidth = imagesx ($img);
	$FullImageHeight = imagesy ($img);
	$Ratio = ($FullImageWidth > $MaxWidth ) ? (real)($MaxWidth / $FullImageWidth) :1;
	$NewWidth = ((int)($FullImageWidth * $Ratio));
	$NewHeight = ((int)($FullImageHeight * $Ratio));
	$Ratio = ( $NewHeight > $MaxHeight ) ? (real)($MaxHeight / $NewHeight) : 1 ;
	$NewWidth = ((int)($NewWidth * $Ratio));
	$NewHeight = ((int)($NewHeight * $Ratio));
	if ( $NewWidth == $FullImageWidth && $NewHeight == $FullImageHeight )copy ( $ImageFilePath, $NewImageFilePath );
	$full_id = ImageCreateTrueColor( $NewWidth , $NewHeight );
	ImageCopyResized( $full_id, $img,0,0, 0,0, $NewWidth, $NewHeight,$FullImageWidth, $FullImageHeight );
	$ReturnVal = ( $full = imagejpeg( $full_id, $NewImageFilePath, 80 )&& $ReturnVal == 1 ) ? "1" : "0";
	ImageDestroy( $full_id );
	return ($ReturnVal) ? TRUE : FALSE ;

}

function CResizeImage($Source, $destination = NULL,$wdt, $height = NULL)
{
// CUT PHOTO FROM CENTER 

	if(empty($height))
	{
		// Height is nit set so we are keeping the same aspect ratio.
		list($width, $height) = getimagesize($Source);
		if($width > $height)
		{
			$w = $wdt;
			$h = ($height / $width) * $w;
			$w = $w;
		}
		else
		{
			$w = $wdt;
			$h = $w;
			$w = ($width / $height) * $w;
		}
	}
	else
	{
	
		
	
		// Both width and Height are set.
		// this will reshape to the new sizes.
		$w = $wdt;
		$h = $height;
	}



		$SourceImage = @file_get_contents($Source);
		if (!$SourceImage)
		{
		echo "Could not open".$Source;
		}
		

	
		$SourceImage = imagecreatefromstring($SourceImage);
		if (!$SourceImage)
		{
		echo $Source." is not a valid image";
		}


	
	$sw = imagesx($SourceImage);
	$sh = imagesy($SourceImage);
	$ar = $sw/$sh;
	$tar = $w/$h;
	if($ar >= $tar)
	{
	
		
	
	
		$x1 = round(($sw - ($sw * ($tar/$ar)))/2);
		$x2 = round($sw * ($tar/$ar));
		$y1 = 0;
		$y2 = $sh;
	}
	else
	{
	

		$x1 = 0;
		$y1 = 0;
		$x2 = $sw;
		$y2 = round($sw/$tar);
	}
	

	
	$slate = @imagecreatetruecolor($w, $h) or die('Invalid thumbnail dimmensions');
	imagecopyresampled($slate, $SourceImage, 0, 0, $x1, $y1, $w, $h, $x2, $y2);
	// If $destination is not set this will output the raw image to the browser and not save the file
	if(!$destination) header('Content-type: image/jpeg');
	
	imagejpeg($slate, $destination, 75);
	
	ImageDestroy($slate);
	ImageDestroy($SourceImage);

	return true;
}




function ImageMerge($ImageFileName,$WatermarkFileName,$ImageSaveFile,$WatermarkPosition)
{
	if (stristr("$ImageFileName",".jpg") or stristr("$ImageFileName",".jpeg"))
	{
		$Img1 = imageCreateFromJPEG($ImageFileName);

	}

	if (stristr("$ImageFileName",".png"))
	{
		$Img1 = imageCreateFromPNG($ImageFileName);

	}

	if (stristr("$ImageFileName",".gif"))
	{
		$Img1 = imageCreateFromGIF($ImageFileName);

	}

	if (stristr("$WatermarkFileName",".jpg") or stristr("$WatermarkFileName",".jpeg"))
	{
		$Img2 = imageCreateFromJPEG($WatermarkFileName);

	}

	if (stristr("$WatermarkFileName",".png"))
	{
		$Img2 = imageCreateFromPNG($WatermarkFileName);

	}

	if (stristr("$WatermarkFileName",".gif"))
	{
		$Img2 = imageCreateFromGIF($WatermarkFileName);

	}

	if ($WatermarkPosition=="Center")
	{
		$WaterMarkX = (ImagesX($Img1)/2)-(ImagesX($Img2)/2);
		$WaterMarkY = (ImagesY($Img1)/2)-(ImagesY($Img2)/2);

	}

	if ($WatermarkPosition=="LU")
	{
		$WaterMarkX = 60;
		$WaterMarkY = 60;

	}

	if ($WatermarkPosition=="RU")
	{
		$WaterMarkX = (ImagesX($Img1)-ImagesX($Img2))-60;
		$WaterMarkY = 60;

	}

	if ($WatermarkPosition=="LD")
	{
		$WaterMarkX = 60;
		$WaterMarkY = (ImagesY($Img1)-ImagesY($Img2))-60;

	}

	if ($WatermarkPosition=="RD")
	{
		$WaterMarkX = (ImagesX($Img1)-ImagesX($Img2))-10;
		$WaterMarkY = (ImagesY($Img1)-ImagesY($Img2))-10;
	}

	imagecopy($Img1, $Img2, $WaterMarkX, $WaterMarkY, 0, 0, imagesx($Img2), imagesy($Img2));
	imagejpeg ($Img1,$ImageSaveFile);
	imagedestroy($Img1);

}



?>
