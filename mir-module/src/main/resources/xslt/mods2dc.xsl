<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="3.0"
  xmlns:dc="http://purl.org/dc/elements/1.1/"
  xmlns:fn="http://www.w3.org/2005/xpath-functions"
  xmlns:mcrclassification="http://www.mycore.de/xslt/classification"
  xmlns:mcrmods="http://www.mycore.de/xslt/mods"
  xmlns:mods="http://www.loc.gov/mods/v3"
  xmlns:oai_dc="http://www.openarchives.org/OAI/2.0/oai_dc/"
  xmlns:srw_dc="info:srw/schema/1/dc-schema"
  xmlns:xlink="http://www.w3.org/1999/xlink"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
  exclude-result-prefixes="fn mcrclassification mcrmods mods srw_dc xlink xsl">

  <!-- xmlns:opf="http://www.idpf.org/2007/opf" -->

  <xsl:include href="resource:xslt/default-parameters.xsl" />
  <xsl:include href="xslInclude:functions" />

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

  <xsl:param name="MIR.dc.diniPublType.classificationId" select="'diniPublType'" />
  <xsl:variable name="diniPublTypeClassificationId" select="$MIR.dc.diniPublType.classificationId" />
  <xsl:variable name="diniPublTypeAuthorityURI">
    <xsl:variable name="diniPublTypeClassification" select="document(concat('classification:metadata:0:children:',$diniPublTypeClassificationId))" />
    <xsl:value-of select="$diniPublTypeClassification//label[lang('x-uri')]/@text" />
  </xsl:variable>

  <xsl:param name="MIR.dc.ignoredClassificationIds" select="'diniPublType2022'" />
  <xsl:variable name="ignoredClassificationIds" select="fn:tokenize($MIR.dc.ignoredClassificationIds,',')" />
  <xsl:variable name="ignoredClassificationAuthorityURIs">
    <xsl:for-each select="$ignoredClassificationIds">
      <uri>
        <xsl:variable name="ignoredClassification" select="document(concat('classification:metadata:0:children:',.))" />
        <xsl:value-of select="$ignoredClassification//label[lang('x-uri')]/@text" />
      </uri>
    </xsl:for-each>
  </xsl:variable>

  <xsl:variable name="marcrelator" select="document('classification:metadata:-1:children:marcrelator')" />

  <xsl:template match="/">

    <xsl:variable name="objId" select="mods:mods/@ID" />

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
            <xsl:apply-templates select="." mode="eu-repo-accessRights">
              <xsl:with-param name="objId" select="$objId" />
            </xsl:apply-templates>
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


  <xsl:template match="mods:titleInfo[not(@altFormat)]">
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

  <xsl:template match="mods:classification[@authorityURI=$diniPublTypeAuthorityURI]">
    <dc:type>
      <xsl:value-of select="concat('doc-type:',substring-after(@valueURI, '#'))" />
    </dc:type>
  </xsl:template>

  <xsl:template match="mods:classification">
    <xsl:variable name="authorityURI" select="@authorityURI" />
    <xsl:variable name="subject">
      <xsl:choose>
        <xsl:when test="string-length($authorityURI) &gt; 0">
          <xsl:if test="not($ignoredClassificationAuthorityURIs/uri = $authorityURI)">
            <xsl:value-of select="mcrclassification:current-label-text(mcrmods:to-category(.))"/>
          </xsl:if>
        </xsl:when>
        <xsl:when test="@valueURI"><xsl:value-of select="substring-after(@valueURI, '#')"/></xsl:when>
        <xsl:when test="@value"><xsl:value-of select="@value"/></xsl:when>
        <xsl:otherwise><xsl:value-of select="."/></xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:if test="string-length($subject)&gt;0">
      <dc:subject>
        <xsl:value-of select="$subject"/>
      </dc:subject>
    </xsl:if>
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
          <xsl:if test="position()!=last()">/</xsl:if>
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
      <!-- for ranges see: http://dublincore.org/documents/date-element/ -->
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

    <xsl:if test="@type and contains('isbn issn uri doi lccn uri urn', $type)">
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
          <xsl:otherwise>
            <xsl:value-of select="$type"/>: <xsl:value-of select="."/>
          </xsl:otherwise>
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
      <xsl:variable name="myURI" select="concat('classification:metadata:0:children:rfc5646:',child::*)" />
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

  <xsl:template match="mods:accessCondition[@type='use and reproduction' or @type='restriction on access']">
    <xsl:variable name="license" select="mcrmods:to-category(.)"/>
    <xsl:choose>
      <xsl:when test="$license">
        <xsl:variable name="licenseLink" select="$license//url/@xlink:href" />
        <dc:rights>
          <xsl:choose>
            <xsl:when test="string-length($licenseLink) &gt; 0">
              <xsl:value-of select="$licenseLink" />
            </xsl:when>
            <xsl:when test="$license//category/label[lang('en')]/@text">
              <xsl:value-of select="$license//category/label[lang('en')]/@text" />
            </xsl:when>
            <xsl:otherwise>
              <xsl:value-of select="mcrclassification:current-label-text($license)" />
            </xsl:otherwise>
          </xsl:choose>
        </dc:rights>
      </xsl:when>
      <xsl:otherwise>
        <dc:rights>
          <xsl:value-of select="." />
        </dc:rights>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="mods:mods" mode="eu-repo-accessRights">
    <xsl:param name="objId" />
    <xsl:choose>
      <xsl:when test="document(concat('userobjectrights:isWorldReadable:',$objId))/boolean = 'true'">
        <dc:rights>
          <xsl:text>info:eu-repo/semantics/openAccess</xsl:text>
        </dc:rights>
      </xsl:when>
      <xsl:when test="mods:accessCondition[@type='embargo']">
        <dc:rights>
          <xsl:text>Fulltext available at </xsl:text> <xsl:value-of select="."/>
        </dc:rights>
        <dc:rights>info:eu-repo/semantics/embargoedAccess</dc:rights>
      </xsl:when>
      <xsl:otherwise>
        <dc:rights>
          <!-- no 'info:eu-repo/semantics/closedAccess' as we have no paywall -->
          <xsl:text>info:eu-repo/semantics/restrictedAccess</xsl:text>
        </dc:rights>
      </xsl:otherwise>
    </xsl:choose>
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
