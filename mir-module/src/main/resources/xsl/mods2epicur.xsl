<?xml version="1.0" encoding="UTF-8"?>

<xsl:stylesheet version="1.0" xmlns="http://www.openarchives.org/OAI/2.0/" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xlink="http://www.w3.org/1999/xlink" xmlns:urn="http://www.ddb.de/standards/urn"
  xmlns:mods="http://www.loc.gov/mods/v3" xmlns:mcr="xalan://org.mycore.common.xml.MCRXMLFunctions" xmlns:mcrurn="xalan://org.mycore.urn.MCRXMLFunctions"
  exclude-result-prefixes="xsl mods mcr mcrurn">

  <xsl:output method="xml" encoding="UTF-8" />
  <xsl:include href="mods2record.xsl" />

  <xsl:param name="ServletsBaseURL" select="''" />
  <xsl:param name="WebApplicationBaseURL" select="''" />
  <xsl:param name="MCR.URN.SubNamespace.Default.Prefix" select="''" />

  <xsl:template match="mycoreobject" mode="metadata">
    <epicur xsi:schemaLocation="urn:nbn:de:1111-2004033116 http://www.persistent-identifier.de/xepicur/version1.0/xepicur.xsd" xmlns="urn:nbn:de:1111-2004033116"
      xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">

      <xsl:variable name="derivateURN">
        <xsl:choose>
          <xsl:when
            test="./structure/derobjects/derobject or contains(./metadata/def.modsContainer/modsContainer/mods:mods/mods:identifier[@type='urn'], $MCR.URN.SubNamespace.Default.Prefix)">
            <xsl:variable name="deriv" select="./structure/derobjects/derobject[mcrurn:hasURNDefined(@xlink:href)]" />
            <xsl:choose>
              <xsl:when test="$deriv">
                <xsl:variable name="derivlink" select="concat('mcrobject:',$deriv[1]/@xlink:href)" />
                <xsl:variable name="derivate" select="document($derivlink)" />
                <xsl:value-of select="$derivate/mycorederivate/derivate/fileset/@urn" />
              </xsl:when>
              <xsl:when
                test="./metadata/def.modsContainer/modsContainer/mods:mods/mods:identifier[@type='urn'] and contains(./metadata/def.modsContainer/modsContainer/mods:mods/mods:identifier[@type='urn'], $MCR.URN.SubNamespace.Default.Prefix)">
                <xsl:value-of select="./metadata/def.modsContainer/modsContainer/mods:mods/mods:identifier[@type='urn']" />
              </xsl:when>
              <xsl:otherwise>
                <xsl:message terminate="yes">
                  Could not find URN in metadata or derivates.
                </xsl:message>
              </xsl:otherwise>
            </xsl:choose>
          </xsl:when>
          <xsl:otherwise>
            <xsl:message terminate="yes">
              <xsl:value-of select="concat('There is no URN defined for ',@ID)" />
            </xsl:message>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:variable>

      <!-- xsl:variable name="epicurType" select="./metadata/urns/urn/@type" / -->
      <xsl:variable name="epicurType" select="'url_update_general'" />
      <administrative_data>
        <delivery>
          <update_status type="{$epicurType}" />
        </delivery>
      </administrative_data>
      <record>
        <identifier scheme="urn:nbn:de">
          <xsl:value-of select="$derivateURN" />
        </identifier>
        <resource>
        <!-- metadata -->
          <identifier scheme="url" role="primary" origin="original" type="frontpage">
            <xsl:if test="$epicurType = 'urn_new' or $epicurType= 'url_update_general'">
              <xsl:attribute name="status">new</xsl:attribute>
            </xsl:if>
            <xsl:value-of select="concat($WebApplicationBaseURL,'receive/', @ID)" />
          </identifier>
        </resource>
        <xsl:apply-templates select="structure/derobjects/derobject" mode="epicurResource" />
      </record>
    </epicur>
  </xsl:template>

  <xsl:template match="derobject" mode="epicurResource">
    <xsl:variable name="derID" select="./@xlink:href" />
    <xsl:variable name="ifslink" select="concat('ifs:',$derID, '/')" />
    <xsl:variable name="details" select="document($ifslink)" />
    <xsl:variable name="filenumber" select="$details/mcr_directory/numChildren/here/files" />
    <xsl:if test="number($filenumber) &gt; 0">
      <resource xmlns="urn:nbn:de:1111-2004033116">
        <xsl:if test="number($filenumber) = 1">
          <xsl:for-each select="$details/mcr_directory/children/child[@type='file']">
            <identifier scheme="url">
              <xsl:value-of select="concat($WebApplicationBaseURL,'servlets/MCRFileNodeServlet/',$derID,'/',mcr:encodeURIPath(./name, true()))" />
            </identifier>
            <format scheme="imt">
              <xsl:value-of select="contentType" />
            </format>
          </xsl:for-each>
        </xsl:if>
        <xsl:if test="number($filenumber) &gt; 1">
          <identifier scheme="url" target="transfer">
            <xsl:value-of select="concat($ServletsBaseURL,'MCRZipServlet/',$derID)" />
          </identifier>
          <format scheme="imt">
            <xsl:value-of select="'application/zip'" />
          </format>
        </xsl:if>
      </resource>
    </xsl:if>
  </xsl:template>

</xsl:stylesheet>