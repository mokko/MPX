<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
 xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:lido="http://www.lido-schema.org"
 xmlns:mpx="http://www.mpx.org/mpx" exclude-result-prefixes="mpx">
 <xsl:strip-space elements="*"/>
 <xsl:output method="text" omit-xml-declaration="yes"/>
 <!--
  simple stat of mpx file with output as text
  see also stat.pl; speed seems about the same
 -->

 <xsl:template match="/">
  <xsl:variable name="sobj"
   select="count (/mpx:museumPlusExport/mpx:sammlungsobjekt)"/>
  <xsl:variable name="perkor"
   select="count (/mpx:museumPlusExport/mpx:personKörperschaft)"/>
  <xsl:variable name="mume"
   select="count (/mpx:museumPlusExport/mpx:multimediaobjekt)"/>

  <xsl:variable name="linkedPerkor"
   select="count (/mpx:museumPlusExport/mpx:personKörperschaft
   [@kueId = ../mpx:sammlungsobjekt/mpx:personKörperschaftRef/@id])"/>

  <xsl:variable name="linkedMume"
   select="count (/mpx:museumPlusExport/mpx:multimediaobjekt
           [mpx:verknüpftesObjekt = ../mpx:sammlungsobjekt/@objId])"/>

  <xsl:text>Sammlungsobjekte: </xsl:text>
  <xsl:value-of select="$sobj"/>
  <xsl:text>&#10;Person/Körperschaften: </xsl:text>
  <xsl:value-of select="$perkor"/>
  <xsl:text>&#10;   davon verlinkt:</xsl:text>
  <xsl:value-of select="$linkedPerkor"/>
  <xsl:text> (</xsl:text>
  <xsl:value-of select="100 div $perkor * $linkedPerkor"/>
  <xsl:text>%)</xsl:text>
  <xsl:text>&#10;Multimediaobjekte: </xsl:text>
  <xsl:value-of select="$mume"/>
  <xsl:text>&#10;   davon verlinkt: </xsl:text>
  <xsl:value-of select="$linkedMume"/>
  <xsl:text> (</xsl:text>
  <xsl:value-of select="100 div $mume * $linkedMume"/>
  <xsl:text>%)</xsl:text>
  <xsl:text>&#10;</xsl:text>
 </xsl:template>

</xsl:stylesheet>
