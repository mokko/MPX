<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
 xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:lido="http://www.lido-schema.org"
 xmlns:mpx="http://www.mpx.org/mpx" exclude-result-prefixes="mpx">
 <xsl:strip-space elements="*"/>

 <!--
  take only the first x sammlungsobjekte and their linked multimediaobjekte and
  personenKorperschaften. This is useful if you want to make a small mpx file
  for test purposes.
  
  Right now I have no clue how I can sort the records in the right order. It 
  seems I would have to get a complete list of objIds first. Or run a sort
  in a second step.
  
  Can't solve this without a internet...i.e. not from this bus
  
 -->
 <xsl:output method="xml" version="1.0" encoding="UTF-8" indent="yes"/>

 <xsl:template match="/">
  <xsl:copy>
   <xsl:apply-templates select="/mpx:museumPlusExport"/>
  </xsl:copy>
 </xsl:template>

 <xsl:template match="/mpx:museumPlusExport">
  <xsl:copy>
   <xsl:apply-templates select="/mpx:museumPlusExport/mpx:sammlungsobjekt">
    <xsl:with-param name="last" select="20"/>
   </xsl:apply-templates>
  </xsl:copy>
 </xsl:template>

 <xsl:template match="/mpx:museumPlusExport/mpx:sammlungsobjekt">
  <xsl:param name="last"/>
  <xsl:if test="position() &lt;= $last">
   <xsl:variable name="objId" select="@objid"/>
   <xsl:variable name="kueId" select="mpx:personKörperschaftRef/@id"/>

   <xsl:copy-of select="../mpx:multimediaobjekt[mpx:verknüpftesObjekt = $objId]"/>
   <xsl:if test="$kueId">
    <xsl:copy-of select="../mpx:personKörperschaft[@kueId =$kueId]"/>
   </xsl:if>
   <xsl:copy-of select="."/>
  </xsl:if>
 </xsl:template>
</xsl:stylesheet>
