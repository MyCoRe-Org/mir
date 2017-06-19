<?xml version="1.0" encoding="UTF-8"?>

<xsl:stylesheet version="1.0"
  xmlns="http://www.openarchives.org/OAI/2.0/"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:mods="http://www.loc.gov/mods/v3"
  xmlns:oai_dc="http://www.openarchives.org/OAI/2.0/oai_dc/"
  xmlns:dc="http://purl.org/dc/elements/1.1/"
  xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
  xmlns:xlink="http://www.w3.org/1999/xlink"
  xmlns:mcr="xalan://org.mycore.common.xml.MCRXMLFunctions"
  exclude-result-prefixes="xsl xlink mods mcr"
>

  <xsl:param name="ServletsBaseURL" select="''" />
  <xsl:param name="HttpSession" select="''" />

  <xsl:include href="mods2dc.xsl" />
  <xsl:include href="mods2record.xsl" />
  <xsl:include href="mods-utils.xsl" />

<xsl:template match="mycoreobject" mode="metadata">

  <xsl:variable name="objId" select="@ID" />

  <!-- derivate variables -->
  <xsl:variable name="derivId">
    <xsl:if test="./structure/derobjects/derobject">
      <xsl:value-of select="./structure/derobjects/derobject/@xlink:href" />
    </xsl:if>
  </xsl:variable>

  <xsl:for-each select="//mods:mods">
    <oai_dc:dc
           xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
           xsi:schemaLocation="http://www.openarchives.org/OAI/2.0/oai_dc/  http://www.openarchives.org/OAI/2.0/oai_dc.xsd">


            <xsl:apply-templates select="mods:titleInfo" />
            <xsl:apply-templates select="mods:name" />
            <xsl:apply-templates select="mods:genre" />
            <xsl:apply-templates select="mods:typeOfResource" />
            <xsl:apply-templates select="mods:identifier[@type='doi']" />
            <xsl:apply-templates select="mods:identifier[@type='urn']" />
            <dc:identifier>
              <xsl:value-of select="concat($WebApplicationBaseURL, 'receive/', $objId)"></xsl:value-of>
            </dc:identifier>
            <xsl:if test="string-length($derivId) &gt; 0">
              <xsl:variable name="derivateXML"  select="document(concat('mcrobject:',$derivId))" />
              <xsl:variable name="maindoc"      select="$derivateXML/mycorederivate/derivate/internals/internal/@maindoc" />
              <xsl:variable name="filePath"     select="concat($derivId,'/',mcr:encodeURIPath($maindoc),$HttpSession)" />
              <dc:identifier>
                <xsl:value-of select="concat($ServletsBaseURL, 'MCRFileNodeServlet/', $filePath)" />
              </dc:identifier>
            </xsl:if>
            <xsl:apply-templates select="mods:identifier[not(@type='doi')][not(@type='urn')]" />
            <xsl:apply-templates select="mods:location" />
            <xsl:apply-templates select="mods:classification" />
            <xsl:apply-templates select="mods:subject" />
            <xsl:apply-templates select="mods:abstract" />
            <xsl:apply-templates select="mods:originInfo" />
            <xsl:apply-templates select="mods:dateIssued" />
            <xsl:apply-templates select="mods:dateCreated" />
            <xsl:apply-templates select="mods:dateCaptured" />
            <xsl:apply-templates select="mods:temporal" />
            <xsl:apply-templates select="mods:physicalDescription" />
            <xsl:apply-templates select="mods:language" />
            <xsl:apply-templates select="mods:relatedItem" />
            <xsl:apply-templates select="mods:accessCondition" />

    </oai_dc:dc>
  </xsl:for-each>
</xsl:template>

</xsl:stylesheet>
