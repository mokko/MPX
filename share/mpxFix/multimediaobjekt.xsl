<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
 version="1.0" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns="http://www.mpx.org/mpx"
 xmlns:mpx="http://www.mpx.org/mpx">

 <!--
  Fix #1: Add multimediaobjekt/@typ, @freigabe, @priorität
  -where attributes does not yet exist
  -guess type based on file extension,
  -current typ values: /Bild|Audio|Video|Text/
  -set freigabe=Web for Standardbild or default to 'intern'
  -set priorität to 10 for Standardbild
 -->
 <xsl:template match="/mpx:museumPlusExport/mpx:multimediaobjekt">
  <xsl:copy>
   <xsl:if test="not (@typ)">
    <xsl:if test="mpx:multimediaErweiterung">
     <xsl:message>
      <xsl:text>//mpx:multimediaobjekt/@typ: add typ based on multimediaErweiterung</xsl:text>
     </xsl:message>
     <xsl:attribute name="typ">
      <xsl:call-template name="choosetyp"/>
     </xsl:attribute>
    </xsl:if>
   </xsl:if>

   <xsl:choose>
    <xsl:when test="mpx:standardbild">
     <xsl:attribute name="freigabe">web</xsl:attribute>
    </xsl:when>
    <xsl:when test="not (@freigabe = 'Web' or @freigabe = 'web')">
     <xsl:message>
      <xsl:text>//mpx:multimediaobjekt/@freigabe: standardbild:reset to Web</xsl:text>
     </xsl:message>
    </xsl:when>
    <xsl:when test="not(mpx:standardbild) and not (@freigabe)">
     <xsl:attribute name="freigabe">intern</xsl:attribute>
     <xsl:message>
      <xsl:text>//mpx:multimediaobjekt/@freigabe: add default value</xsl:text>
     </xsl:message>
    </xsl:when>
    <xsl:when test="@freigabe">
     <xsl:attribute name="freigabe">
	  <xsl:value-of select="."/>
	 </xsl:attribute>
    </xsl:when>
   </xsl:choose>

   <xsl:if test="not (@priorität)">
    <xsl:if test="mpx:standardbild">
     <xsl:attribute name="priorität">10</xsl:attribute>
     <xsl:message>
      <xsl:text>//mpx:multimediaobjekt/@priorität: add 10 for standardbild</xsl:text>
     </xsl:message>
    </xsl:if>
   </xsl:if>
   <xsl:apply-templates select="@*|node()"/>
  </xsl:copy>
 </xsl:template>


 <xsl:template match="/mpx:museumPlusExport/mpx:multimediaobjekt/@typ[.= '']">
  <xsl:message>
   <xsl:text>empty typ</xsl:text>
   <xsl:value-of select="."/>
  </xsl:message>
 </xsl:template>


 <xsl:template name="choosetyp">
  <xsl:variable name="smallcase" select="'abcdefghijklmnopqrstuvwxyz'"/>
  <xsl:variable name="uppercase" select="'ABCDEFGHIJKLMNOPQRSTUVWXYZ'"/>

  <xsl:variable name="ext"
   select="translate(mpx:multimediaErweiterung, $uppercase, $smallcase)"/>
  <!-- xsl:message><xsl:value-of select="$ext"/></xsl:message -->
  <xsl:choose>
   <xsl:when test="$ext = 'jpg' or 
				$ext = 'tif' or 
				$ext = 'tiff'">
    <xsl:text>Bild</xsl:text>
   </xsl:when>
   <xsl:when test="$ext = 'mp3' or 
				$ext = 'wav'">
    <xsl:text>Audio</xsl:text>
   </xsl:when>
   <xsl:when test="$ext = 'mpeg' or 
				$ext = 'mpg' or 
				$ext = 'avi'">
    <xsl:text>Video</xsl:text>
   </xsl:when>
   <xsl:when test="$ext = 'wpd'">
    <xsl:text>Text</xsl:text>
   </xsl:when>
   <xsl:otherwise>
    <xsl:message>
     <xsl:text>Add multimediaobjekt/@typ: Erweiterung empty; assume </xsl:text>
     <xsl:text>default "Bild"</xsl:text>
     <!-- xsl:value-of select="text(.)" / -->
    </xsl:message>
   </xsl:otherwise>
  </xsl:choose>
 </xsl:template>
</xsl:stylesheet>