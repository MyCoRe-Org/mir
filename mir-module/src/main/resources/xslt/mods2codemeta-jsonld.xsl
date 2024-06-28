<?xml version="1.0"?>
<xsl:stylesheet version="3.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:fn="http://www.w3.org/2005/xpath-functions"
  xmlns:xlink="http://www.w3.org/1999/xlink"
  xmlns:mods="http://www.loc.gov/mods/v3"
  exclude-result-prefixes="xlink mods">

  <xsl:output method="text" encoding="UTF-8" media-type="application/json" />

  <xsl:param name="WebApplicationBaseURL" />

  <xsl:template match="/">
    <xsl:variable name="node">
      <fn:map>
        <fn:string key="@context">https://doi.org/10.5063/schema/codemeta-2.0</fn:string>
        <fn:string key="@id">
          <xsl:value-of select="concat($WebApplicationBaseURL,'receive/',/mycoreobject/@ID)" />
        </fn:string>
        <xsl:apply-templates select="mycoreobject/metadata/def.modsContainer/modsContainer/mods:mods" />
      </fn:map>
    </xsl:variable>
    <xsl:copy-of select="fn:xml-to-json($node)" />
  </xsl:template>

  <xsl:template match="mods:mods">
    <xsl:if test="mods:titleInfo[1]/mods:title">
      <fn:string key="schema:name">
        <xsl:value-of select="mods:titleInfo[1]/mods:title" />
      </fn:string>
    </xsl:if>
    <xsl:if test="mods:abstract">
      <fn:string key="description">
        <xsl:value-of select="mods:abstract" />
      </fn:string>
    </xsl:if>
    <xsl:variable name="keyword" select="mods:subject[@xlink:type='simple']/mods:topic" />
    <xsl:if test="count($keyword) &gt; 0">
      <fn:array key="keywords">
        <xsl:for-each select="$keyword">
          <fn:string>
            <xsl:value-of select="." />
          </fn:string>
        </xsl:for-each>
      </fn:array>
    </xsl:if>
    <xsl:if test="mods:originInfo[@eventType='creation']/mods:dateCreated[@encoding='w3cdtf']">
      <fn:string key="dateCreated">
        <xsl:value-of select="mods:originInfo[@eventType='creation']/mods:dateCreated[@encoding='w3cdtf']" />
      </fn:string>
    </xsl:if>
    <xsl:if test="mods:originInfo[@eventType='update']/mods:dateModified[@encoding='w3cdtf']">
      <fn:string key="dateModified">
        <xsl:value-of select="mods:originInfo[@eventType='update']/mods:dateModified[@encoding='w3cdtf']" />
      </fn:string>
    </xsl:if>
    <xsl:if test="mods:originInfo[@eventType='publication']/mods:dateIssued[@encoding='w3cdtf']">
      <fn:string key="datePublished">
        <xsl:value-of select="mods:originInfo[@eventType='publication']/mods:dateIssued[@encoding='w3cdtf']" />
      </fn:string>
    </xsl:if>
    <xsl:variable name="creator" select="mods:name[mods:role/mods:roleTerm[@authority='marcrelator' and @type='code']/text()='cre']" />
    <xsl:if test="count($creator) &gt; 0">
      <fn:array key="creator">
        <xsl:call-template name="parse-name">
          <xsl:with-param name="name" select="$creator" />
        </xsl:call-template>
      </fn:array>
    </xsl:if>
    <xsl:variable name="contributor" select="mods:name[mods:role/mods:roleTerm[@authority='marcrelator' and @type='code']/text()='ctb']" />
    <xsl:if test="count($contributor) &gt; 0">
      <fn:array key="contributor">
        <xsl:call-template name="parse-name">
          <xsl:with-param name="name" select="$contributor" />
        </xsl:call-template>
      </fn:array>
    </xsl:if>
    <xsl:variable name="copyrightHolder" select="mods:name[mods:role/mods:roleTerm[@authority='marcrelator' and @type='code']/text()='cph']" />
    <xsl:if test="count($copyrightHolder) &gt; 0">
      <fn:array key="copyrightHolder">
        <xsl:call-template name="parse-name">
          <xsl:with-param name="name" select="$copyrightHolder" />
        </xsl:call-template>
      </fn:array>
    </xsl:if>
    <xsl:variable name="publisher" select="mods:name[mods:role/mods:roleTerm[@authority='marcrelator' and @type='code']/text()='pbl']" />
    <xsl:if test="count($publisher) &gt; 0">
      <fn:array key="publisher">
        <xsl:call-template name="parse-name">
          <xsl:with-param name="name" select="$publisher" />
        </xsl:call-template>
      </fn:array>
    </xsl:if>
    <xsl:variable name="provider" select="mods:name[mods:role/mods:roleTerm[@authority='marcrelator' and @type='code']/text()='prv']" />
    <xsl:if test="count($provider) &gt; 0">
      <fn:array key="provider">
        <xsl:call-template name="parse-name">
          <xsl:with-param name="name" select="$provider" />
        </xsl:call-template>
      </fn:array>
    </xsl:if>
    <xsl:variable name="maintainer" select="mods:name[mods:role/mods:roleTerm[@authority='marcrelator' and @type='code']/text()='led']" />
    <xsl:if test="count($maintainer) &gt; 0">
      <fn:array key="maintainer">
        <xsl:call-template name="parse-name">
          <xsl:with-param name="name" select="$maintainer" />
        </xsl:call-template>
      </fn:array>
    </xsl:if>
    <xsl:variable name="funder" select="mods:name[mods:role/mods:roleTerm[@authority='marcrelator' and @type='code']/text()='fnd']" />
    <xsl:if test="count($funder) &gt; 0">
      <fn:array key="funder">
        <xsl:call-template name="parse-name">
          <xsl:with-param name="name" select="$funder" />
        </xsl:call-template>
      </fn:array>
    </xsl:if>
    <xsl:variable name="sponsor" select="mods:name[mods:role/mods:roleTerm[@authority='marcrelator' and @type='code']/text()='spn']" />
    <xsl:if test="count($sponsor) &gt; 0">
      <fn:array key="sponsor">
        <xsl:call-template name="parse-name">
          <xsl:with-param name="name" select="$sponsor" />
        </xsl:call-template>
      </fn:array>
    </xsl:if>
    <xsl:if test="mods:accessCondition[@type='embargo']">
      <fn:string key="embargoDate">
        <xsl:value-of select="mods:accessCondition[@type='embargo']" />
      </fn:string>
    </xsl:if>
    <xsl:if test="count(mods:relatedItem[@type='isReferencedBy']) &gt; 0">
      <fn:array key="referencePublication">
        <xsl:call-template name="parse-relatedItem">
          <xsl:with-param name="relatedItem" select="mods:relatedItem[@type='references']" />
        </xsl:call-template>
      </fn:array>
    </xsl:if>
    <xsl:if test="count(mods:relatedItem[@type='host']) &gt; 0">
      <fn:array key="isPartOf">
        <xsl:call-template name="parse-relatedItem">
          <xsl:with-param name="relatedItem" select="mods:relatedItem[@type='host']" />
        </xsl:call-template>
      </fn:array>
    </xsl:if>
    <xsl:if test="count(mods:relatedItem[@type='constituent']) &gt; 0">
      <fn:array key="hasPart">
        <xsl:call-template name="parse-relatedItem">
          <xsl:with-param name="relatedItem" select="mods:relatedItem[@type='constituent']" />
        </xsl:call-template>
      </fn:array>
    </xsl:if>
    <xsl:if test="count(mods:identifier) &gt; 0">
      <xsl:call-template name="parse-identifier">
        <xsl:with-param name="identifier" select="mods:identifier" />
      </xsl:call-template>
    </xsl:if>
    <xsl:if test="count(mods:accessCondition[@xlink:href]) &gt; 0">
      <xsl:call-template name="parse-license">
        <xsl:with-param name="license" select="mods:accessCondition[@xlink:href]" />
      </xsl:call-template>
    </xsl:if>
    <!-- TODO funding -->
    <!-- TODO isAccessibleForFree always true? -->
    <!-- TODO supportingData -->
    <!-- TODO softwareHelp -->
    <!-- TODO targetProduct -->
    <!-- readme -->
    <!-- developmentStatus -->
    <!-- version -->
    <!-- applicationCategory -->
    <!-- applicationSubCategory -->
    <!-- programmingLanguage -->
    <!-- operatingSystem -->
    <!-- processorRequirements -->
    <!-- memoryRequirements -->
    <!-- storageRequirements -->
    <!-- runtimePlatform -->
    <!-- softwareRequirements -->
    <!-- softwareSuggestions -->
    <!-- permissions -->
    <!-- codeRepository -->
    <!-- buildInstructions -->
    <!-- releaseNotes -->
    <!-- contIntegration -->
    <!-- issueTracker -->
    <xsl:copy-of select="mods:extension[@displayLabel='codemeta-part']/fn:map/*" copy-namespaces="no" />
  </xsl:template>

  <xsl:template name="parse-relatedItem">
    <xsl:param name="relatedItem" />
    <xsl:for-each select="$relatedItem">
      <fn:map>
        <xsl:choose>
          <xsl:when test="@type='references'">
            <fn:string key="@type">http://schema.org/ScholarlyArticle</fn:string>
          </xsl:when>
          <xsl:otherwise>
            <fn:string key="@type">http://schema.org/CreativeWork</fn:string>
          </xsl:otherwise>
        </xsl:choose>
        <xsl:if test="mods:titleInfo/mods:title">
          <fn:string key="title">
            <xsl:value-of select="mods:titleInfo/mods:title" />
          </fn:string>
        </xsl:if>
        <xsl:if test="@xlink:href">
          <fn:string key="url">
            <xsl:value-of select="@xlink:href" />
          </fn:string>
        </xsl:if>
      </fn:map>
    </xsl:for-each>
  </xsl:template>

  <!-- https://github.com/ESIPFed/science-on-schema.org/issues/13 -->
  <!-- https://github.com/ESIPFed/science-on-schema.org/pull/94 -->
  <xsl:template name="parse-identifier">
    <xsl:param name="identifier" />
    <fn:array key="identifier">
      <xsl:for-each select="$identifier">
        <fn:map>
          <fn:string key="@type">schema:PropertyValue</fn:string>
          <fn:string key="schema:propertyID">
            <xsl:value-of select="concat('http://purl.org/spar/datacite/', @type)" />
          </fn:string>
          <fn:string key="schema:value">
            <xsl:value-of select="concat(@type, ':', text())" />
          </fn:string>
        </fn:map>
      </xsl:for-each>
    </fn:array>
  </xsl:template>

  <xsl:template name="parse-name">
    <xsl:param name="name" />
    <xsl:for-each select="$name">
      <xsl:variable name="type">
        <xsl:choose>
          <xsl:when test="@type='corporate'">
            <xsl:value-of select="'Organization'" />
          </xsl:when>
          <xsl:otherwise>
            <xsl:value-of select="'Person'" />
          </xsl:otherwise>
        </xsl:choose>
      </xsl:variable>
      <fn:map>
        <fn:string key="@type">
          <xsl:value-of select="$type" />
        </fn:string>
        <xsl:choose>
          <!-- always use the displayName for name-->
          <xsl:when test="mods:displayForm">
            <fn:string key="name">
              <xsl:value-of select="mods:displayForm" />
            </fn:string>
          </xsl:when>
          <xsl:otherwise>
            <xsl:if test="$type='Person' and (mods:namePart[@type='given'] and mods:namePart[@type='family'])">
              <fn:string key="givenName">
                <xsl:value-of select="mods:namePart[@type='given']" />
              </fn:string>
              <fn:string key="familyName">
                <xsl:value-of select="mods:namePart[@type='family']" />
              </fn:string>
            </xsl:if>
          </xsl:otherwise>
        </xsl:choose>
        <xsl:if test="$type='Person' and mods:affiliation">
          <fn:string key="affiliation">
            <xsl:value-of select="mods:affiliation" />
          </fn:string>
        </xsl:if>
        <xsl:if test="count(mods:nameIdentifier) &gt; 0">
          <xsl:call-template name="parse-identifier">
            <xsl:with-param name="identifier" select="mods:nameIdentifier" />
          </xsl:call-template>
        </xsl:if>
      </fn:map>
    </xsl:for-each>
  </xsl:template>

  <xsl:template name="parse-license">
    <xsl:param name="license" />
    <fn:array key="license">
      <xsl:for-each select="$license">
        <xsl:variable name="trimmed" select="substring-after(normalize-space(@xlink:href),'#')" />
        <xsl:variable name="licenseURI" select="concat('classification:metadata:0:children:mir_licenses:',$trimmed)" />
        <xsl:choose>
          <xsl:when test="$trimmed='rights_reserved'">
            <fn:map>
              <fn:string key="@type">http://schema.org/CreativeWork</fn:string>
              <fn:string key="name">
                <xsl:value-of select="document($licenseURI)//category/label[@xml:lang='en']/@text" />
              </fn:string>
            </fn:map>
          </xsl:when>
          <xsl:otherwise>
            <xsl:variable name="url" select="document($licenseURI)//category/url/@xlink:href" />
            <xsl:if test="string-length($url)>0">
              <fn:string>
                <xsl:value-of select="$url" />
              </fn:string>
            </xsl:if>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:for-each>
    </fn:array>
  </xsl:template>
</xsl:stylesheet>
