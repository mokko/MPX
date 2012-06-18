<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
 xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:lido="http://www.lido-schema.org"
 xmlns:mpx="http://www.mpx.org/mpx" exclude-result-prefixes="mpx">
 <xsl:strip-space elements="*"/>

 <!-- 
 drop perKor and Mume records which are not linked from sammlungsobjekt 
 -->


 <xsl:template match="@*|node()">
  <xsl:copy>
   <xsl:apply-templates select="@*|node()"/>
  </xsl:copy>
 </xsl:template>

 <xsl:template match="/mpx:museumPlusExport/mpx:multimediaobjekt">
  <xsl:if
   test="mpx:verknüpftesObjekt and mpx:verknüpftesObjekt = ../mpx:sammlungsobjekt/@objId">
   <xsl:copy>
    <xsl:apply-templates select="@*|node()"/>
   </xsl:copy>
  </xsl:if>
 </xsl:template>

 <xsl:template match="/mpx:museumPlusExport/mpx:personKörperschaft">
  <xsl:if test="@kueId = ../mpx:sammlungsobjekt/mpx:personKörperschaftRef/@id">
   <xsl:copy>
    <xsl:apply-templates select="@*|node()"/>
   </xsl:copy>
  </xsl:if>
 </xsl:template>
</xsl:stylesheet>
