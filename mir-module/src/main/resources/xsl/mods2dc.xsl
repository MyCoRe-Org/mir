<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet version="1.0" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
  xmlns:mods="http://www.loc.gov/mods/v3"
  xmlns:dc="http://purl.org/dc/elements/1.1/"
  xmlns:srw_dc="info:srw/schema/1/dc-schema"
  xmlns:oai_dc="http://www.openarchives.org/OAI/2.0/oai_dc/"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xlink="http://www.w3.org/1999/xlink"
  xmlns:mcrmods="xalan://org.mycore.mods.classification.MCRMODSClassificationSupport"
  xmlns:mcrxsl="xalan://org.mycore.common.xml.MCRXMLFunctions"
  exclude-result-prefixes="xsl mods mcrmods mcrxsl xlink srw_dc">

  <!-- xmlns:opf="http://www.idpf.org/2007/opf" -->

  <xsl:param name="WebApplicationBaseURL" select="''" />
  <xsl:param name="MCR.URN.Resolver.MasterURL" select="''" />
  <xsl:param name="MCR.DOI.Resolver.MasterURL" select="''" />
  <!--
  Version 1.4		2013-12-13 tmee@loc.gov
  Upgraded to MODS 3.5

  Version 1.3		2013-12-09 tmee@loc.gov
  Fixed date transformation for dates without start/end points

  Version 1.2		2012-08-12 WS
  Upgraded to MODS 3.4

  Revision 1.1	2007-05-18 tmee@loc.gov
  Added modsCollection conversion to DC SRU
  Updated introductory documentation

  Version 1.0		2007-05-04 tmee@loc.gov

  This stylesheet transforms MODS version 3.4 records and collections of records to simple Dublin Core (DC) records,
  based on the Library of Congress' MODS to simple DC mapping <http://www.loc.gov/standards/mods/mods-dcsimple.html>

  The stylesheet will transform a collection of MODS 3.4 records into simple Dublin Core (DC)
  as expressed by the SRU DC schema <http://www.loc.gov/standards/sru/dc-schema.xsd>

  The stylesheet will transform a single MODS 3.4 record into simple Dublin Core (DC)
  as expressed by the OAI DC schema <http://www.openarchives.org/OAI/2.0/oai_dc.xsd>

  Because MODS is more granular than DC, transforming a given MODS element or subelement to a DC element frequently results in less precise tagging,
  and local customizations of the stylesheet may be necessary to achieve desired results.

  This stylesheet makes the following decisions in its interpretation of the MODS to simple DC mapping:

  When the roleTerm value associated with a name is creator, then name maps to dc:creator
  When there is no roleTerm value associated with name, or the roleTerm value associated with name is a value other than creator, then name maps to dc:contributor
  Start and end dates are presented as span dates in dc:date and in dc:coverage
  When the first subelement in a subject wrapper is topic, subject subelements are strung together in dc:subject with hyphens separating them
  Some subject subelements, i.e., geographic, temporal, hierarchicalGeographic, and cartographics, are also parsed into dc:coverage
  The subject subelement geographicCode is dropped in the transform

-->

  <xsl:output method="xml" indent="yes"/>

  <xsl:variable name="marcrelator" select="document('classification:metadata:-1:children:marcrelator')" />

  <xsl:template match="/">

    <xsl:variable name="objId" select="@ID" />

    <xsl:choose>
      <!-- WS: updated schema location -->
      <xsl:when test="//mods:modsCollection">
        <srw_dc:dcCollection
          xsi:schemaLocation="info:srw/schema/1/dc-schema http://www.loc.gov/standards/sru/resources/dc-schema.xsd">
          <xsl:apply-templates/>
          <xsl:for-each select="mods:modsCollection/mods:mods">
            <srw_dc:dc
              xsi:schemaLocation="info:srw/schema/1/dc-schema http://www.loc.gov/standards/sru/resources/dc-schema.xsd">
              <xsl:apply-templates/>
            </srw_dc:dc>
          </xsl:for-each>
        </srw_dc:dcCollection>
      </xsl:when>
      <xsl:otherwise>
        <xsl:for-each select="mods:mods">
            <oai_dc:dc
            xsi:schemaLocation="http://www.openarchives.org/OAI/2.0/oai_dc/ http://www.openarchives.org/OAI/2.0/oai_dc.xsd">
            <xsl:apply-templates select="mods:titleInfo" />
            <xsl:apply-templates select="mods:name" />
            <xsl:apply-templates select="mods:genre" />
            <xsl:apply-templates select="mods:typeOfResource" />
            <xsl:apply-templates select="mods:identifier[@type='doi']" />
            <xsl:apply-templates select="mods:identifier[@type='urn']" />
            <dc:identifier>
              <xsl:value-of select="concat($WebApplicationBaseURL, 'receive/', $objId)"></xsl:value-of>
            </dc:identifier>
            <xsl:apply-templates select="mods:identifier[not(@type='doi')][not(@type='urn')]" />
            <xsl:apply-templates select="mods:location" />
            <xsl:apply-templates select="mods:classification" />
            <xsl:apply-templates select="mods:subject" />
            <xsl:apply-templates select="mods:abstract" />
            <xsl:apply-templates select="." mode="dc_date" />
            <xsl:apply-templates select="mods:originInfo" />
            <xsl:apply-templates select="mods:temporal" />
            <xsl:apply-templates select="mods:physicalDescription" />
            <xsl:apply-templates select="mods:language" />
            <xsl:apply-templates select="mods:relatedItem" />
            <xsl:apply-templates select="mods:accessCondition" />
          </oai_dc:dc>
        </xsl:for-each>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <!-- Paul Borchert remove interna-->
    <xsl:template match="*[@xlink:href!='']">
    </xsl:template>
    <xsl:template match="mods:name[@ID!='']">
    </xsl:template>
    <xsl:template match="mods:classification[contains (@authorityURI,'classifications/status')]">
    </xsl:template>
    <xsl:template match="mods:classification[contains (@authorityURI,'classifications/annual_review')]">
    </xsl:template>


  <xsl:template match="mods:titleInfo">
    <dc:title>
      <xsl:value-of select="mods:nonSort"/>
      <xsl:if test="mods:nonSort">
        <xsl:text> </xsl:text>
      </xsl:if>
      <xsl:value-of select="mods:title"/>
      <xsl:if test="mods:subTitle">
        <xsl:text>: </xsl:text>
        <xsl:value-of select="mods:subTitle"/>
      </xsl:if>
      <xsl:if test="mods:partNumber">
        <xsl:text>. </xsl:text>
        <xsl:value-of select="mods:partNumber"/>
      </xsl:if>
      <xsl:if test="mods:partName">
        <xsl:text>. </xsl:text>
        <xsl:value-of select="mods:partName"/>
      </xsl:if>
    </dc:title>
  </xsl:template>

  <!-- tmee mods 3.5 -->

  <xsl:template match="mods:name">
    <xsl:choose>
      <xsl:when test="mods:role/mods:roleTerm[@type='code']">
        <xsl:variable name="role" select="mods:role/mods:roleTerm[@type='code']" />
        <xsl:choose>
          <xsl:when test="$marcrelator//category[@ID=$role]/ancestor-or-self::category[@ID='cre']">
            <dc:creator>
              <xsl:call-template name="name"/>
            </dc:creator>
          </xsl:when>
          <xsl:when test="$marcrelator//category[@ID=$role]/ancestor-or-self::category[@ID='ctb']">
            <dc:contributor>
              <xsl:call-template name="name"/>
            </dc:contributor>
          </xsl:when>
          <!-- we are sure that we have matched all creators or contributors -->
        </xsl:choose>
      </xsl:when>
      <xsl:when test="mods:role/mods:roleTerm[@type='text']='creator' or mods:role/mods:roleTerm[@type='text']='author'">
        <dc:creator>
          <xsl:call-template name="name"/>
        </dc:creator>
      </xsl:when>
      <xsl:otherwise>
        <dc:contributor>
          <xsl:comment>fallback no marcrelator role found</xsl:comment>
          <xsl:call-template name="name"/>
        </dc:contributor>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="mods:classification[@authority='sdnb'] | mods:classification[@authority='ddc']">
    <dc:subject>
      <xsl:value-of select="concat('ddc:',.)" />
    </dc:subject>
  </xsl:template>

  <xsl:template match="mods:classification[@authorityURI='http://www.mycore.org/classifications/diniPublType']">
    <dc:type>
      <xsl:value-of select="concat('doc-type:',substring-after(@valueURI,'#'))" />
    </dc:type>
  </xsl:template>

  <xsl:template match="mods:classification">

    <xsl:variable name="classlink" select="mcrmods:getClassCategLink(.)" />

    <dc:subject>
    <xsl:choose>
      <xsl:when test="string-length($classlink) &gt; 0"><xsl:value-of select="document($classlink)/mycoreclass/categories/category/label/@text"/></xsl:when>
      <xsl:when test="@valueURI"><xsl:value-of select="substring-after(@valueURI, '#')"/></xsl:when>
      <xsl:when test="@value"><xsl:value-of select="@value"/></xsl:when>
      <xsl:otherwise><xsl:value-of select="."/></xsl:otherwise>
    </xsl:choose>
    </dc:subject>
  </xsl:template>

  <xsl:template
    match="mods:subject[mods:topic | mods:name | mods:occupation | mods:geographic | mods:hierarchicalGeographic | mods:cartographics | mods:temporal] ">
    <dc:subject>
      <xsl:for-each select="mods:topic | mods:occupation">
        <xsl:value-of select="."/>
        <xsl:if test="position()!=last()"><xsl:text> -- </xsl:text></xsl:if>
      </xsl:for-each>
      <xsl:for-each select="mods:name">
        <xsl:call-template name="name"/>
      </xsl:for-each>
    </dc:subject>

    <xsl:for-each select="mods:titleInfo/mods:title">
      <dc:subject>
        <xsl:value-of select="mods:titleInfo/mods:title"/>
      </dc:subject>
    </xsl:for-each>

    <xsl:for-each select="mods:geographic">
      <dc:coverage>
        <xsl:value-of select="."/>
      </dc:coverage>
    </xsl:for-each>

    <xsl:for-each select="mods:hierarchicalGeographic">
      <dc:coverage>
        <xsl:for-each
          select="mods:continent|mods:country|mods:provence|mods:region|mods:state|mods:territory|mods:county|mods:city|mods:island|mods:area">
          <xsl:value-of select="."/>
          <xsl:if test="position()!=last()"><xsl:text> -- </xsl:text></xsl:if>
        </xsl:for-each>
      </dc:coverage>
    </xsl:for-each>

    <xsl:for-each select="mods:cartographics/*">
      <dc:coverage>
        <xsl:value-of select="."/>
      </dc:coverage>
    </xsl:for-each>

    <xsl:if test="mods:temporal">
      <dc:coverage>
        <xsl:for-each select="mods:temporal">
          <xsl:value-of select="."/>
          <xsl:if test="position()!=last()">-</xsl:if>
        </xsl:for-each>
      </dc:coverage>
    </xsl:if>

    <xsl:if test="*[1][local-name()='topic'] and *[local-name()!='topic']">
      <dc:subject>
        <xsl:for-each
          select="*[local-name()!='cartographics' and local-name()!='geographicCode' and local-name()!='hierarchicalGeographic'] ">
          <xsl:value-of select="."/>
          <xsl:if test="position()!=last()"><xsl:text> -- </xsl:text></xsl:if>
        </xsl:for-each>
      </dc:subject>
    </xsl:if>
  </xsl:template>

  <xsl:template match="mods:abstract[not(@altFormat)] | mods:tableOfContents[not(@altFormat)] | mods:note">
    <!--  <xsl:if test="@xlink:href!=''"> -->
        <dc:description>
          <xsl:value-of select="."/>
        </dc:description>
    <!-- </xsl:if> -->
  </xsl:template>

  <xsl:template match="mods:originInfo">
    <xsl:for-each select="mods:publisher">
      <dc:publisher>
        <xsl:value-of select="."/>
      </dc:publisher>
    </xsl:for-each>
  </xsl:template>
  
  <xsl:template match="mods:mods" mode="dc_date">
    <xsl:choose>
      <xsl:when test="mods:originInfo/mods:dateIssued[@point='start']">
        <xsl:apply-templates select="mods:originInfo/mods:dateIssued[@point='start']" />
      </xsl:when>
      <xsl:when test="mods:originInfo/mods:dateIssued">
        <xsl:apply-templates select="mods:originInfo/mods:dateIssued[1]" />
      </xsl:when>
      <xsl:when test="mods:originInfo/mods:dateCreated[@point='start']">
        <xsl:apply-templates select="mods:originInfo/mods:dateCreated[@point='start']" />
      </xsl:when>
      <xsl:when test="mods:originInfo/mods:dateCreated">
        <xsl:apply-templates select="mods:originInfo/mods:dateCreated[1]" />
      </xsl:when>
      <xsl:when test="mods:originInfo/mods:dateCaptured[@point='start']">
        <xsl:apply-templates select="mods:originInfo/mods:dateCaptured[@point='start']" />
      </xsl:when>
      <xsl:when test="mods:originInfo/mods:dateCaptured">
        <xsl:apply-templates select="mods:originInfo/mods:dateCaptured[1]" />
      </xsl:when>
      <xsl:otherwise>
        <dc:date>
          <xsl:comment>metadata creation date</xsl:comment>
          <xsl:value-of select="substring-before(../../../../service/servdates/servdate[@type='createdate'],'T')" />
        </dc:date>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="mods:dateIssued | mods:dateCreated | mods:dateCaptured">
    <dc:date>
      <xsl:value-of select="."/>
    </dc:date>
  </xsl:template>

  <xsl:template
    match="mods:dateIssued[@point='start'] | mods:dateCreated[@point='start'] | mods:dateCaptured[@point='start'] | mods:dateOther[@point='start'] ">
    <xsl:variable name="dateName" select="local-name()"/>
    <dc:date>
      <xsl:value-of select="concat(., '/', ../*[local-name()=$dateName and @point='end'])" />
    </dc:date>
  </xsl:template>

  <xsl:template match="mods:temporal[@point='start']  ">
    <xsl:value-of select="."/>-<xsl:value-of select="../mods:temporal[@point='end']"/>
  </xsl:template>

  <xsl:template match="mods:temporal[@point!='start' and @point!='end']  ">
    <xsl:value-of select="."/>
  </xsl:template>
  <xsl:template match="mods:genre">
    <xsl:choose>
      <xsl:when test="@authority='dct'">
        <dc:type>
          <xsl:value-of select="."/>
        </dc:type>
      </xsl:when>
      <xsl:when test="@authority='marcgt'">
        <dc:type>
          <xsl:value-of select="."/>
        </dc:type>
      </xsl:when>
      <xsl:when test="contains(@valueURI,'#')">
        <dc:type>
          <xsl:value-of select="substring-after(@valueURI,'#')"/>
        </dc:type>
      </xsl:when>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="mods:typeOfResource">
    <xsl:if test="@collection='yes'">
      <dc:type>Collection</dc:type>
    </xsl:if>
    <xsl:if test=". ='software' and ../mods:genre='database'">
      <dc:type>Dataset</dc:type>
    </xsl:if>
    <xsl:if test=".='software' and ../mods:genre='online system or service'">
      <dc:type>Service</dc:type>
    </xsl:if>
    <xsl:if test=".='software'">
      <dc:type>Software</dc:type>
    </xsl:if>
    <xsl:if test=".='cartographic material'">
      <dc:type>Image</dc:type>
    </xsl:if>
    <xsl:if test=".='multimedia'">
      <dc:type>InteractiveResource</dc:type>
    </xsl:if>
    <xsl:if test=".='moving image'">
      <dc:type>MovingImage</dc:type>
    </xsl:if>
    <xsl:if test=".='three dimensional object'">
      <dc:type>PhysicalObject</dc:type>
    </xsl:if>
    <xsl:if test="starts-with(.,'sound recording')">
      <dc:type>Sound</dc:type>
    </xsl:if>
    <xsl:if test=".='still image'">
      <dc:type>StillImage</dc:type>
    </xsl:if>
    <xsl:if test=". ='text'">
      <dc:type>Text</dc:type>
    </xsl:if>
    <xsl:if test=".='notated music'">
      <dc:type>Text</dc:type>
    </xsl:if>
  </xsl:template>

  <xsl:template match="mods:physicalDescription">
    <xsl:for-each select="mods:extent | mods:form | mods:internetMediaType">
      <dc:format>

        <!-- tmee mods 3.5 -->
        <xsl:variable name="unit"
          select="translate(@unit,'ABCDEFGHIJKLMNOPQRSTUVWXYZ','abcdefghijklmnopqrstuvwxyz')"/>
        <xsl:if test="@unit">
          <xsl:value-of select="$unit"/>:
        </xsl:if>
        <xsl:value-of select="."/>
      </dc:format>
    </xsl:for-each>
  </xsl:template>
  <!--
  <xsl:template match="mods:mimeType">
    <dc:format>
      <xsl:value-of select="."/>
    </dc:format>
  </xsl:template>
-->

  <xsl:template match="mods:identifier">
      <xsl:variable name="type"
        select="translate(@type,'ABCDEFGHIJKLMNOPQRSTUVWXYZ','abcdefghijklmnopqrstuvwxyz')"/>

        <xsl:if test="contains ('isbn issn uri doi lccn uri urn', $type)">
    <dc:identifier>

      <xsl:choose>
        <xsl:when test="@type='urn'">
            <xsl:value-of select="concat($MCR.URN.Resolver.MasterURL, .)" />
        </xsl:when>
        <xsl:when test="@type='doi'">
          <xsl:value-of select="concat($MCR.DOI.Resolver.MasterURL, .)" />
        </xsl:when>
        <xsl:when test="@type='hdl'">
            <xsl:text>http://hdl.handle.net/</xsl:text>
            <xsl:value-of select="." />
        </xsl:when>
        <xsl:when test="contains(.,':')">
          <xsl:value-of select="."/>
        </xsl:when>
        <xsl:when test="@type">
          <xsl:value-of select="$type"/>: <xsl:value-of select="."/>
        </xsl:when>
        <xsl:when test="contains ('isbn issn uri doi lccn uri', $type)">
          <xsl:value-of select="$type"/>: <xsl:value-of select="."/>
        </xsl:when>
      </xsl:choose>
    </dc:identifier>

      </xsl:if>
  </xsl:template>


  <xsl:template match="mods:location">
    <xsl:for-each select="mods:url[not(contains(text(), $WebApplicationBaseURL))]">
      <dc:identifier>
        <xsl:value-of select="."/>
      </dc:identifier>
    </xsl:for-each>
  </xsl:template>

  <xsl:template match="mods:language">
    <!-- Best Practice: use ISO 639-3 (since DRIVER Guidelines v2) -->
    <dc:language>
      <xsl:variable name="myURI" select="concat('classification:metadata:0:children:rfc4646:',child::*)" />
      <xsl:value-of select="document($myURI)//label[@xml:lang='x-term']/@text"/>
    </dc:language>
  </xsl:template>

  <xsl:template
    match="mods:relatedItem[mods:titleInfo | mods:name | mods:identifier | mods:location]">
    <xsl:choose>
      <xsl:when test="@type='original'">
        <dc:source>
          <xsl:for-each
            select="mods:titleInfo/mods:title | mods:identifier | mods:location/mods:url">
            <xsl:if test="normalize-space(.)!= ''">
              <xsl:value-of select="."/>
              <xsl:if test="position()!=last()"><xsl:text> -- </xsl:text></xsl:if>
            </xsl:if>
          </xsl:for-each>
        </dc:source>
      </xsl:when>
      <xsl:when test="@type='series'"/>
      <xsl:otherwise>
        <dc:relation>
          <xsl:for-each
            select="mods:titleInfo/mods:title | mods:identifier | mods:location/mods:url">
            <xsl:if test="normalize-space(.)!= ''">
              <xsl:value-of select="."/>
              <xsl:if test="position()!=last()"><xsl:text> -- </xsl:text></xsl:if>
            </xsl:if>
          </xsl:for-each>
        </dc:relation>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="mods:identifier[@type='open-aire']">
    <dc:relation>
      <xsl:value-of select="."/>
    </dc:relation>
  </xsl:template>

  <!-- von Paul Borchert -->
  <xsl:template match="mods:accessCondition[@type='embargo']">
    <dc:rights>
      <xsl:text>Fulltext available at </xsl:text> <xsl:value-of select="."/>
    </dc:rights>
    <dc:rights>info:eu-repo/semantics/embargoedAccess</dc:rights>
  </xsl:template>

  <xsl:template match="mods:accessCondition[@type='use and reproduction']">
    <xsl:variable name="trimmed" select="substring-after(normalize-space(@xlink:href),'#')" />
    <xsl:variable name="licenseURI" select="concat('classification:metadata:0:children:mir_licenses:',$trimmed)" />
    <xsl:variable name="licenseLink" select="document($licenseURI)//url/@xlink:href" />
    <dc:rights>
      <xsl:choose>
        <xsl:when test="string-length($licenseLink) &gt; 0">
          <xsl:value-of select="$licenseLink" />
        </xsl:when>
        <xsl:when test="contains($trimmed, 'rights_reserved')">
          <xsl:apply-templates select="." mode="rights_reserved" />
        </xsl:when>
        <xsl:when test="contains($trimmed, 'oa_nlz')">
          <xsl:apply-templates select="." mode="oa_nlz" />
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="mcrxsl:getDisplayName('mir_licenses',$trimmed)" />
        </xsl:otherwise>
      </xsl:choose>
    </dc:rights>
    <xsl:if test="(contains($trimmed, 'cc_') or contains($trimmed, 'oa_')) and not(../mods:accessCondition[@type='restriction on access']) and not(../mods:accessCondition[@type='embargo'])">
      <dc:rights>
        <xsl:text>info:eu-repo/semantics/openAccess</xsl:text>
      </dc:rights>
    </xsl:if>
  </xsl:template>

  <xsl:template match="mods:accessCondition[@type='restriction on access']">
    <dc:rights>
      <xsl:choose>
        <xsl:when test="contains(substring-after(@xlink:href, '#'), 'intern')">
          <xsl:text>info:eu-repo/semantics/closedAccess</xsl:text>
        </xsl:when>
        <xsl:when test="contains(substring-after(@xlink:href, '#'), 'ipAddressRange')">
          <xsl:text>info:eu-repo/semantics/restrictedAccess</xsl:text>
        </xsl:when>
        <xsl:when test="contains(substring-after(@xlink:href, '#'), 'unlimited')">
          <xsl:text>info:eu-repo/semantics/openAccess</xsl:text>
        </xsl:when>
      </xsl:choose>
    </dc:rights>
  </xsl:template>

  <xsl:template name="name">
    <!-- xsl:if test="mods:role[mods:roleTerm[@authority='marcrelator' and @type='code']]">
      <xsl:attribute name="opf:role">
        <xsl:value-of select="mods:role/mods:roleTerm[@authority='marcrelator' and @type='code'][1]" />
      </xsl:attribute>
    </xsl:if -->
    <xsl:variable name="name">
      <xsl:choose>
        <xsl:when test="mods:etal">
          <xsl:value-of select="et.al." />
        </xsl:when>
        <xsl:when test="mods:displayForm">
          <xsl:value-of select="mods:displayForm" />
        </xsl:when>
        <xsl:when test="mods:namePart[not(@type)]">
          <xsl:for-each select="mods:namePart[not(@type)]">
            <xsl:choose>
              <xsl:when test="position() = 1">
                <xsl:value-of select="text()"/>
              </xsl:when>
              <xsl:otherwise>
                <xsl:value-of select="concat(' ', text())"/>
              </xsl:otherwise>
            </xsl:choose>
          </xsl:for-each>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="mods:namePart[@type='family']" />
          <xsl:if test="mods:namePart[@type='given']">
            <xsl:value-of select="concat(', ',mods:namePart[@type='given'])" />
          </xsl:if>
          <xsl:if test="mods:namePart[@type='date']">
            <xsl:value-of select="concat(' (',mods:namePart[@type='date'],')')" />
          </xsl:if>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:value-of select="normalize-space($name)"/>
  </xsl:template>

  <!-- suppress all else:-->
  <xsl:template match="*"/>


</xsl:stylesheet>
