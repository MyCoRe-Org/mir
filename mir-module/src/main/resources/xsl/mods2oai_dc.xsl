<?xml version="1.0" encoding="UTF-8"?>

<xsl:stylesheet version="1.0"
  xmlns="http://www.openarchives.org/OAI/2.0/"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:mods="http://www.loc.gov/mods/v3"
  xmlns:oai_dc="http://www.openarchives.org/OAI/2.0/oai_dc/"
  xmlns:dc="http://purl.org/dc/elements/1.1/"
  xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
  xmlns:mcrurn="xalan://org.mycore.urn.MCRXMLFunctions"
  xmlns:xlink="http://www.w3.org/1999/xlink"
  xmlns:mcr="xalan://org.mycore.common.xml.MCRXMLFunctions"
  exclude-result-prefixes="xsl xlink mods mcrurn mcr"
>

  <xsl:param name="ServletsBaseURL" select="''" />
  <xsl:param name="WebApplicationBaseURL" select="''" />
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
  <xsl:variable name="derivateURN">
    <xsl:choose>
      <xsl:when test="string-length($derivId) &gt; 0">
        <xsl:variable name="derivlink" select="concat('mcrobject:',$derivId)" />
        <xsl:variable name="derivate" select="document($derivlink)" />
        <xsl:choose>
          <xsl:when test="mcrurn:hasURNDefined($derivId)">
            <xsl:value-of select="$derivate/mycorederivate/derivate/fileset/@urn" />
          </xsl:when>
          <xsl:otherwise>
            <xsl:value-of select="''" />
          </xsl:otherwise>
        </xsl:choose>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="''" />
      </xsl:otherwise>
    </xsl:choose>
  </xsl:variable>

  <xsl:for-each select="//mods:mods">
    <oai_dc:dc
           xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
           xsi:schemaLocation="http://www.openarchives.org/OAI/2.0/oai_dc/  http://www.openarchives.org/OAI/2.0/oai_dc.xsd">
      <xsl:apply-templates/>

      <xsl:if test="string-length($derivateURN) &gt; 0">
      <dc:identifier>
        <xsl:text>http://nbn-resolving.de/</xsl:text>
        <xsl:value-of select="$derivateURN" />
      </dc:identifier>
      </xsl:if>

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

    </oai_dc:dc>
  </xsl:for-each>
</xsl:template>

</xsl:stylesheet>
