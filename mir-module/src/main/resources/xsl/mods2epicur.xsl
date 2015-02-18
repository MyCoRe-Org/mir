<?xml version="1.0" encoding="UTF-8"?>

<xsl:stylesheet version="1.0"
  xmlns="http://www.openarchives.org/OAI/2.0/"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
  xmlns:xlink="http://www.w3.org/1999/xlink"
  xmlns:urn="http://www.ddb.de/standards/urn"
  xmlns:mods="http://www.loc.gov/mods/v3"
  xmlns:mcrurn="xalan://org.mycore.urn.MCRXMLFunctions"
  exclude-result-prefixes="xsl mods mcrurn"
>

  <xsl:output method="xml" encoding="UTF-8" />
  <xsl:include href="mods2record.xsl" />

  <xsl:param name="ServletsBaseURL" select="''" />
  <xsl:param name="JSessionID" select="''" />
  <xsl:param name="WebApplicationBaseURL" select="''" />

  <xsl:template match="mycoreobject" mode="metadata">
    <xsl:text disable-output-escaping="yes">&lt;epicur xsi:schemaLocation="urn:nbn:de:1111-2004033116 http://www.persistent-identifier.de/xepicur/version1.0/xepicur.xsd"
                xmlns="urn:nbn:de:1111-2004033116" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"&gt;</xsl:text>

    <xsl:variable name="derivateURN">
      <xsl:choose>
        <xsl:when test="./structure/derobjects/derobject">
          <xsl:variable name="deriv" select="./structure/derobjects/derobject/@xlink:href" />
          <xsl:variable name="derivlink" select="concat('mcrobject:',$deriv)" />
          <xsl:variable name="derivate" select="document($derivlink)" />
          <xsl:choose>
            <xsl:when test="mcrurn:hasURNDefined($deriv)">
              <xsl:value-of select="$derivate/mycorederivate/derivate/fileset/@urn" />
            </xsl:when>
            <xsl:otherwise>
              <xsl:value-of select="'urn_new'" />
            </xsl:otherwise>
          </xsl:choose>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="'urn_new'" />
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>

    <!-- ToDo: define epicurType in derivate xml -->
    <!-- xsl:variable name="epicurType" select="./metadata/urns/urn/@type" / -->
    <xsl:variable name="epicurType" select="'urn_new'" />
    <xsl:call-template name="administrative_data">
      <xsl:with-param name="epicurType" select="$epicurType" />
    </xsl:call-template>
    <xsl:call-template name="record">
      <xsl:with-param name="epicurType" select="$epicurType" />
      <xsl:with-param name="derivateURN" select="$derivateURN" />
    </xsl:call-template>
    <xsl:text disable-output-escaping="yes">&lt;/epicur&gt;</xsl:text>
  </xsl:template>

  <xsl:template name="linkQueryURL">
    <xsl:param name="id" />
    <xsl:value-of select="concat('mcrobject:',$id)" />
  </xsl:template>

  <xsl:template name="linkDerDetailsURL">
    <xsl:param name="host" select="'local'" />
    <xsl:param name="id" />
    <xsl:variable name="derivbase"
      select="concat($ServletsBaseURL,'MCRFileNodeServlet/',$id,'/')" />
    <xsl:value-of
      select="concat($derivbase,'?MCRSessionID=',$JSessionID,'&amp;hosts=',$host,'&amp;XSL.Style=xml')" />
  </xsl:template>

  <xsl:template name="linkClassQueryURL">
    <xsl:param name="type" select="'class'" />
    <xsl:param name="host" select="'local'" />
    <xsl:param name="classid" select="''" />
    <xsl:param name="categid" select="''" />
    <xsl:value-of
      select="concat($ServletsBaseURL,'MCRQueryServlet',$JSessionID,'?XSL.Style=xml&amp;type=',$type,'&amp;hosts=',$host,'&amp;query=%2Fmycoreclass%5B%40ID%3D%27',$classid,'%27%20and%20*%2Fcategory%2F%40ID%3D%27',$categid,'%27%5D')" />
  </xsl:template>

  <xsl:template name="administrative_data">
    <xsl:param name="epicurType" select="''" />
    <xsl:element name="administrative_data" namespace="urn:nbn:de:1111-2004033116">
      <xsl:element name="delivery" namespace="urn:nbn:de:1111-2004033116">
        <xsl:element name="update_status" namespace="urn:nbn:de:1111-2004033116">
          <xsl:attribute name="type"><xsl:value-of select="$epicurType" />
        </xsl:attribute></xsl:element>
      </xsl:element>
    </xsl:element>
  </xsl:template>

  <xsl:template name="url_update_general">
  </xsl:template>

  <xsl:template name="record">
    <xsl:param name="epicurType" select="''" />
    <xsl:param name="derivateURN" select="''" />
    <xsl:variable name="mycoreobjectID" select="@ID" />
    <xsl:element name="record" namespace="urn:nbn:de:1111-2004033116">
      <xsl:element name="identifier" namespace="urn:nbn:de:1111-2004033116">
        <xsl:attribute name="scheme">urn:nbn:de</xsl:attribute>
        <xsl:value-of select="$derivateURN" />
      </xsl:element>
      <!-- xsl:if test="$epicurType='urn_new_version'">
        <xsl:element name="isVersionOf" namespace="urn:nbn:de:1111-2004033116">
          <xsl:attribute name="scheme">urn:nbn:de</xsl:attribute>
          <xsl:value-of select="./metadata/urns/urn[@type='urn_first']" />
        </xsl:element>
      </xsl:if -->
      <xsl:element name="resource" namespace="urn:nbn:de:1111-2004033116">
        <xsl:element name="identifier" namespace="urn:nbn:de:1111-2004033116">
          <xsl:attribute name="scheme">url</xsl:attribute>
          <xsl:attribute name="role">primary</xsl:attribute>
          <xsl:attribute name="origin">original</xsl:attribute>
          <xsl:attribute name="type">frontpage</xsl:attribute>
          <xsl:if test="$epicurType = 'urn_new'">
            <xsl:attribute name="status">new</xsl:attribute>
          </xsl:if>
          <xsl:value-of
            select="concat($WebApplicationBaseURL,'receive/', $mycoreobjectID)" />
        </xsl:element>
        <xsl:element name="format" namespace="urn:nbn:de:1111-2004033116">
          <xsl:attribute name="scheme">imt</xsl:attribute>
          <xsl:value-of select="'text/html'" />
        </xsl:element>
      </xsl:element>
      <xsl:for-each select="./structure/derobjects/derobject">
        <xsl:variable name="derID" select="./@xlink:href" />
        <xsl:variable name="filelink"
          select="concat($WebApplicationBaseURL,'servlets/MCRFileNodeServlet/',
                     $derID,'/?hosts=local&amp;XSL.Style=xml')" />
        <xsl:variable name="details" select="document($filelink)" />
        <xsl:variable name="filenumber"
          select="$details/mcr_directory/numChildren/here/files" />



        <xsl:if test="number($filenumber) = 1">
          <xsl:for-each select="$details/mcr_directory/children/child[@type='file']">
            <xsl:element name="resource" namespace="urn:nbn:de:1111-2004033116">
              <xsl:element name="identifier" namespace="urn:nbn:de:1111-2004033116">
                <xsl:attribute name="scheme">url</xsl:attribute>
                <xsl:value-of
                  select="concat($WebApplicationBaseURL,'servlets/MCRFileNodeServlet/',$derID,'/',./name)" />
              </xsl:element>
              <xsl:element name="format" namespace="urn:nbn:de:1111-2004033116">
                <xsl:attribute name="scheme">imt</xsl:attribute>
                <xsl:value-of select="./contentType" />
              </xsl:element>
            </xsl:element>
          </xsl:for-each>
        </xsl:if>
        <xsl:if test="number($filenumber) &gt; 1">
          <xsl:element name="resource" namespace="urn:nbn:de:1111-2004033116">
            <xsl:element name="identifier" namespace="urn:nbn:de:1111-2004033116">
              <xsl:attribute name="scheme">url</xsl:attribute>
              <xsl:attribute name="target">transfer</xsl:attribute>
              <xsl:value-of
                select="concat($WebApplicationBaseURL,'zip?id=',$derID)" />
            </xsl:element>
            <xsl:element name="format" namespace="urn:nbn:de:1111-2004033116">
              <xsl:attribute name="scheme">imt</xsl:attribute>
              <xsl:value-of select="'application/zip'" />
            </xsl:element>
          </xsl:element>
        </xsl:if>
      </xsl:for-each>
    </xsl:element>
  </xsl:template>
</xsl:stylesheet>