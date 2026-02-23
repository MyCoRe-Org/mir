<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0"
  xmlns="http://www.openarchives.org/OAI/2.0/"
  xmlns:mcracl="xalan://org.mycore.access.MCRAccessManager"
  xmlns:mods="http://www.loc.gov/mods/v3"
  xmlns:urn="http://www.ddb.de/standards/urn"
  xmlns:xalan="http://xml.apache.org/xalan"
  xmlns:xlink="http://www.w3.org/1999/xlink"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
  exclude-result-prefixes="mcracl mods xalan xsl">

  <xsl:output method="xml" encoding="UTF-8" />
  <xsl:include href="mods2record.xsl" />

  <xsl:param name="ServletsBaseURL" select="''" />
  <xsl:param name="WebApplicationBaseURL" select="''" />

  <xsl:variable name="ifsTemp" xmlns="">
    <xsl:for-each select="mycoreobject/structure/derobjects/derobject[mcracl:checkDerivateContentPermission(@xlink:href, 'read')]">
      <der id="{@xlink:href}">
        <xsl:copy-of select="document(concat('xslStyle:mcr_directory-recursive:ifs:',@xlink:href,'/'))" />
      </der>
    </xsl:for-each>
  </xsl:variable>
  <xsl:variable name="ifs" select="xalan:nodeset($ifsTemp)" />

  <xsl:template match="mycoreobject" mode="metadata">
    <epicur xsi:schemaLocation="urn:nbn:de:1111-2004033116 http://www.persistent-identifier.de/xepicur/version1.0/xepicur.xsd" xmlns="urn:nbn:de:1111-2004033116"
      xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">

      <xsl:variable name="urn">
        <xsl:choose>
          <xsl:when test="./metadata/def.modsContainer/modsContainer/mods:mods/mods:identifier[@type='urn']">
            <xsl:value-of select="./metadata/def.modsContainer/modsContainer/mods:mods/mods:identifier[@type='urn']" />
          </xsl:when>
          <xsl:otherwise>
            <xsl:message terminate="yes">
              <xsl:value-of select="concat('There is no URN defined for ',@ID)" />
            </xsl:message>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:variable>

      <xsl:variable name="epicurType" select="'url_update_general'" />
      <administrative_data>
        <delivery>
          <update_status type="{$epicurType}" />
        </delivery>
      </administrative_data>
      <record>
        <identifier scheme="urn:nbn:de">
          <xsl:value-of select="$urn" />
        </identifier>
        <resource>
        <!-- metadata -->
          <identifier scheme="url" role="primary" origin="original" type="frontpage">
            <xsl:if test="$epicurType = 'urn_new' or $epicurType= 'url_update_general'">
              <xsl:attribute name="status">new</xsl:attribute>
            </xsl:if>
            <xsl:value-of select="concat($WebApplicationBaseURL,'receive/', @ID)" />
          </identifier>
          <format scheme="imt">
            <xsl:value-of select="'text/html'" />
          </format>
        </resource>
        <xsl:apply-templates select="$ifs/der" xmlns="" mode="epicurResource" />
      </record>
    </epicur>
  </xsl:template>

  <xsl:template mode="epicurResource" match="der">
    <xsl:variable name="filenumber" select="count(mcr_directory/children//child[@type='file'])" />
    <xsl:choose>
      <xsl:when test="$filenumber = 0" />
      <xsl:when test="$filenumber = 1">
        <resource xmlns="urn:nbn:de:1111-2004033116">
          <xsl:variable name="uri" select="mcr_directory/children//child[@type='file']/uri" />
          <xsl:variable name="derId" select="substring-before(substring-after($uri,':/'), ':')" />
          <xsl:variable name="filePath" select="substring-after(substring-after($uri, ':'), ':')" />
          <identifier scheme="url">
            <xsl:value-of select="concat($ServletsBaseURL,'MCRFileNodeServlet/',$derId,$filePath)" />
          </identifier>
          <format scheme="imt">
            <xsl:value-of select="$uri/../contentType" />
          </format>
        </resource>
      </xsl:when>
      <xsl:otherwise>
        <resource xmlns="urn:nbn:de:1111-2004033116">
          <identifier scheme="url" target="transfer">
            <xsl:value-of select="concat($ServletsBaseURL,'MCRZipServlet/',@id)" />
          </identifier>
          <format scheme="imt">
            <xsl:value-of select="'application/zip'" />
          </format>
        </resource>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

</xsl:stylesheet>
