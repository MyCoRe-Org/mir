<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:mods="http://www.loc.gov/mods/v3" xmlns:xalan="http://xml.apache.org/xalan" xmlns:xlink="http://www.w3.org/1999/xlink"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform" exclude-result-prefixes="xalan"
>

  <xsl:output encoding="UTF-8" media-type="text/plain" method="text" standalone="yes" indent="no" />

  <xsl:strip-space elements="*" />

  <xsl:template match="/">
    <xsl:for-each select="mods:mods">
      <xsl:if test="contains(mods:identifier[@type='uri']/text(),'PPN=')">
        <xsl:text>0100  </xsl:text>
        <xsl:value-of select="substring-after(mods:identifier[@type='uri']/text(), 'PPN=')" />
        <xsl:text>&#10;</xsl:text>
      </xsl:if>
      <xsl:apply-templates select="." mode="pica3" />
    </xsl:for-each>
  </xsl:template>

  <xsl:template match="mods:titleInfo[not(@altFormat)]" mode="pica3">
    <xsl:text>4000  </xsl:text>
    <xsl:value-of select="mods:title" />
    <xsl:text> ; </xsl:text>
    <xsl:value-of select="mods:subTitle" />
    <xsl:text>&#10;</xsl:text>
  </xsl:template>

  <xsl:template match="mods:abstract[not(@altFormat)]" mode="pica3">
    <xsl:text>4207  </xsl:text>
    <xsl:value-of select="normalize-space(translate(.,'&#xA;&#xD;',' '))" />
    <xsl:text>&#10;</xsl:text>
  </xsl:template>

  <xsl:template match="mods:subject/mods:topic" mode="pica3">
    <xsl:text>5580  </xsl:text>
    <xsl:value-of select="." />
    <xsl:text>&#10;</xsl:text>
  </xsl:template>

  <xsl:template match="mods:name[@type='personal']" mode="pica3">
    <xsl:if test="mods:role/mods:roleTerm='aut'">
      <xsl:text>3000  </xsl:text>
      <xsl:value-of select="mods:displayForm" />
      <xsl:text>&#10;</xsl:text>
    </xsl:if>
  </xsl:template>

  <xsl:template match="mods:identifier[@type='doi']" mode="pica3">
    <xsl:text>4083  http://dx.doi.org/</xsl:text>
    <xsl:value-of select="." />
    <xsl:text>&#10;</xsl:text>
  </xsl:template>
  <xsl:template match="mods:identifier[@type='doi']" mode="relatedItem">
    <xsl:text>4083  http://dx.doi.org/</xsl:text>
    <xsl:value-of select="." />
    <xsl:text>&#10;</xsl:text>
  </xsl:template>
  <xsl:template match="mods:identifier[@type='urn']" mode="pica3">
    <xsl:text>4083  http://nbn-resolving.de/</xsl:text>
    <xsl:value-of select="." />
    <xsl:text>&#10;</xsl:text>
  </xsl:template>
  <xsl:template match="mods:identifier[@type='issn']" mode="relatedItem">
    <xsl:text>2010  </xsl:text>
    <xsl:value-of select="." />
    <xsl:text>&#10;</xsl:text>
  </xsl:template>
  <xsl:template match="mods:identifier[@type='zdbid']" mode="relatedItem">
    <xsl:text>2110  </xsl:text>
    <xsl:value-of select="." />
    <xsl:text>&#10;</xsl:text>
  </xsl:template>
 <!-- xsl:template match="mods:identifier[@type='intern_old']" mode="pica3">
    <xsl:text>OldInternID  </xsl:text> <xsl:value-of select="." /> <xsl:text>&#10;</xsl:text>
 </xsl:template -->
 <!-- xsl:template match="mods:identifier[@type='citekey']" mode="pica3">
    <xsl:text>Citekey  </xsl:text> <xsl:value-of select="." /> <xsl:text>&#10;</xsl:text>
 </xsl:template -->

  <xsl:template match="mods:relatedItem[@type='host']" mode="pica3">
    <xsl:apply-templates mode="relatedItem" />
  </xsl:template>

  <xsl:template match="mods:originInfo/mods:issuance" mode="relatedItem">
  </xsl:template>

  <xsl:template match="mods:originInfo/mods:issuance" mode="relatedItem">
  </xsl:template>

  <xsl:template match="mods:genre" mode="relatedItem">
   <!-- Hier muss geprüft werden ob es wirklich eine Zeitschrift ist oder oben im related Item Template-->
  </xsl:template>

  <xsl:template match="mods:titleInfo/mods:title" mode="relatedItem">
    <xsl:text>4000  </xsl:text>
    <xsl:value-of select="." />
    <xsl:text>&#10;</xsl:text>
  </xsl:template>

  <xsl:template match="mods:originInfo" mode="relatedItem">
    <xsl:text>4030  </xsl:text>
    <xsl:choose>
      <xsl:when test="mods:place/mods:placeTerm">
        <xsl:value-of select="mods:place/mods:placeTerm" />
        <xsl:text>,</xsl:text>
      </xsl:when>
      <xsl:otherwise>
        <xsl:text>o.A.</xsl:text>
      </xsl:otherwise>
    </xsl:choose>
    <xsl:value-of select="mods:publisher" />
    <xsl:text>&#10;</xsl:text>
  </xsl:template>

  <xsl:template match="mods:part" mode="relatedItem">
    <xsl:text>4070   </xsl:text>
    <xsl:apply-templates mode="relatedItem" />
    <xsl:text>&#10;</xsl:text>
  </xsl:template>

  <xsl:template match="mods:detail[@type='issue']" mode="relatedItem">
    <xsl:text>/a</xsl:text>
    <xsl:value-of select="mods:number" />
  </xsl:template>

  <xsl:template match="mods:detail[@type='volume']" mode="relatedItem">
    <xsl:text>/v</xsl:text>
    <xsl:value-of select="mods:number" />
  </xsl:template>

  <xsl:template match="mods:extent[@unit='pages']" mode="relatedItem">
    <xsl:text>/p</xsl:text>
    <xsl:value-of select="mods:start" />
    <xsl:text>-</xsl:text>
    <xsl:value-of select="mods:end" />
  </xsl:template>

  <xsl:template match="mods:date" mode="relatedItem">
    <xsl:text>/j</xsl:text>
    <xsl:value-of select="." />
  </xsl:template>

  <xsl:template match="mods:dateIssued" mode="relatedItem">
  </xsl:template>

  <xsl:template match="mods:note" mode="pica3">
  </xsl:template>

  <xsl:template match="mods:dateIssued" mode="pica3">
    <xsl:text>1100  </xsl:text>
    <xsl:value-of select="." />
    <xsl:text>&#10;</xsl:text>
  </xsl:template>

  <xsl:template match="mods:genre[@authority='marcgt']" mode="pica3">
  </xsl:template>

  <!-- ========== ignore the rest ========== -->
  <xsl:template match="node()|@*">
   <!-- xsl:message terminate="no">
    WARNING: Unmatched element: <xsl:value-of select="name()"/>
   </xsl:message -->
    <xsl:apply-templates />
  </xsl:template>

  <xsl:template match="node()|@*" mode="pica3">
    <!-- xsl:message terminate="no">
      WARNING: Unmatched pica3 element: <xsl:value-of select="name()"/>
     </xsl:message -->
    <xsl:apply-templates mode="pica3" />
  </xsl:template>

  <xsl:template match="node()|@*" mode="relatedItem">
    <!-- xsl:message terminate="no">
      WARNING: Unmatched relatedItem element: <xsl:value-of select="name()"/>
    </xsl:message -->
    <xsl:apply-templates mode="relatedItem" />
  </xsl:template>

</xsl:stylesheet>
