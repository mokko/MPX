<xsl:stylesheet version="1.0" xmlns="http://www.mpx.org/mpx"
 xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
 xmlns:mpx="http://www.mpx.org/mpx" exclude-result-prefixes="mpx">

<!-- 
 IMPORTANT: with xsltproc or XML::LibXML this transformation doesn't sort right!
 It does with saxon however so I consider the xsl correct and libXML buggy.
-->

 <xsl:output method="xml" version="1.0" encoding="UTF-8" indent="yes"/>
 <xsl:strip-space elements="*"/>

 <xsl:template match="/">
  <museumPlusExport>
   <!-- sort multimediaobject by ascending @mulId -->
   <xsl:for-each select="/mpx:museumPlusExport/mpx:multimediaobjekt">
    <xsl:sort data-type="number" select="@mulId"/>
    <xsl:call-template name="descendants"/>
   </xsl:for-each>

   <!-- personKörperschaft -->

   <xsl:for-each select="/mpx:museumPlusExport/mpx:personKörperschaft">
    <!-- sort perKor attributes numerically -->
    <xsl:sort data-type="number" select="@kueId"/>
    <xsl:call-template name="descendants"/>
   </xsl:for-each>
   <!-- SAMMLUNGSOBJEKT -->

   <xsl:for-each select="/mpx:museumPlusExport/mpx:sammlungsobjekt">
    <xsl:sort data-type="number" select="@objId"/>
    <xsl:call-template name="descendants"/>
   </xsl:for-each>
  </museumPlusExport>
 </xsl:template>

 <xsl:template name="descendants">
  <!-- e.g. sammlungsobjekt -->
  <xsl:element name="{name()}">
   <xsl:for-each select="@*">
    <xsl:sort case-order="lower-first" lang="de" data-type="text" select="name(.)"/>
    <!-- e.g. @objId -->
    <xsl:attribute name="{name()}">
     <xsl:value-of select="."/>
    </xsl:attribute>
   </xsl:for-each>
   <xsl:for-each select="descendant::*">
    <!-- sort descendant elements alphabetically, e.g. bearbDatum -->
    <xsl:sort lang="de" data-type="text" select="name(.)"/>
    <xsl:element name="{name()}">
     <!-- sort descendant attributes alphabetically -->
     <xsl:for-each select="@*">
      <xsl:sort lang="de" data-type="text" select="name(.)"/>
      <xsl:attribute name="{name()}">
       <xsl:value-of select="."/>
      </xsl:attribute>
     </xsl:for-each>
     <xsl:apply-templates/>
    </xsl:element>
   </xsl:for-each>
  </xsl:element>
 </xsl:template>
</xsl:stylesheet>