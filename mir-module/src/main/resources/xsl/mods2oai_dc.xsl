<?xml version="1.0" encoding="UTF-8"?>

<xsl:stylesheet version="1.0"
  xmlns:oai="http://www.openarchives.org/OAI/2.0/"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:mods="http://www.loc.gov/mods/v3"
  xmlns:oai_dc="http://www.openarchives.org/OAI/2.0/oai_dc/"
  xmlns:dc="http://purl.org/dc/elements/1.1/"
  xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
  xmlns:xlink="http://www.w3.org/1999/xlink"
  xmlns:mcr="xalan://org.mycore.common.xml.MCRXMLFunctions"
  xmlns:xalan="http://xml.apache.org/xalan"
  exclude-result-prefixes="xalan xsl xlink mods mcr"
>

  <xsl:param name="ServletsBaseURL" select="''" />
  <xsl:param name="HttpSession" select="''" />

  <xsl:include href="mods2dc.xsl" />
  <xsl:include href="mods2record.xsl" />
  <xsl:include href="mods-utils.xsl" />

<xsl:template match="mycoreobject" mode="metadata">

  <xsl:variable name="ifsTemp">
    <xsl:for-each select="structure/derobjects/derobject[mcr:isDisplayedEnabledDerivate(@xlink:href)]">
      <der id="{@xlink:href}">
        <xsl:copy-of select="document(concat('xslStyle:mcr_directory-recursive:ifs:',@xlink:href,'/'))" />
      </der>
    </xsl:for-each>
  </xsl:variable>
  <xsl:variable name="ifs" select="xalan:nodeset($ifsTemp)" />

  <xsl:variable name="objId" select="@ID" />

  <xsl:for-each select="metadata/def.modsContainer/modsContainer/mods:mods">
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
            <xsl:if test="$ifs/der">
              <xsl:variable name="filenumber" select="count($ifs/der/mcr_directory/children//child[@type='file'])" />
              <xsl:variable name="dernumber" select="count($ifs/der)" />
              <dc:identifier>
                <xsl:choose>
                  <xsl:when test="$filenumber = 1">
                    <xsl:variable name="uri" select="$ifs/der/mcr_directory/children//child[@type='file']/uri" />
                    <xsl:variable name="derId" select="substring-before(substring-after($uri,':/'), ':')" />
                    <xsl:variable name="filePath" select="substring-after(substring-after($uri, ':'), ':')" />
                    <xsl:value-of select="concat($ServletsBaseURL,'MCRFileNodeServlet/',$derId,$filePath)" />
                  </xsl:when>
                  <xsl:otherwise>
                    <xsl:choose>
                      <xsl:when test="$dernumber = 1">
                        <xsl:value-of select="concat($ServletsBaseURL,'MCRZipServlet/',$ifs/der/@id)" />
                      </xsl:when>
                      <xsl:otherwise>
                        <xsl:value-of select="concat($ServletsBaseURL,'MCRZipServlet/',$objId)" />
                      </xsl:otherwise>
                    </xsl:choose>
                  </xsl:otherwise>
                </xsl:choose>
              </dc:identifier>
            </xsl:if>
            <xsl:apply-templates select="mods:identifier[not(@type='doi')][not(@type='urn')]" />
            <xsl:apply-templates select="mods:location" />
            <xsl:apply-templates select="mods:classification" />
            <xsl:apply-templates select="mods:subject" />
            <xsl:apply-templates select="mods:abstract" />
            <xsl:apply-templates select="mods:originInfo" />
            <xsl:apply-templates select="." mode="dc_date" />
            <xsl:apply-templates select="mods:temporal" />
            <xsl:apply-templates select="mods:physicalDescription" />
            <xsl:apply-templates select="mods:language" />
            <xsl:apply-templates select="mods:relatedItem" />
            <xsl:apply-templates select="mods:accessCondition" />
            <xsl:apply-templates select="." mode="eu-repo-accessRights">
              <xsl:with-param name="objId" select="$objId" />
            </xsl:apply-templates>

    </oai_dc:dc>
  </xsl:for-each>
</xsl:template>

</xsl:stylesheet>
