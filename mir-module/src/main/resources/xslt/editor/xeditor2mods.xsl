<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0"
  xmlns:exslt="http://exslt.org/common"
  xmlns:mcr="http://www.mycore.org/"
  xmlns:mcrid="xalan://org.mycore.datamodel.metadata.MCRObjectID"
  xmlns:mcrmodsclass="xalan://org.mycore.mods.classification.MCRMODSClassificationSupport"
  xmlns:mcrpages="xalan://org.mycore.mods.MCRMODSPagesHelper"
  xmlns:mcrxml="xalan://org.mycore.common.xml.MCRXMLFunctions"
  xmlns:mods="http://www.loc.gov/mods/v3"
  xmlns:xlink="http://www.w3.org/1999/xlink"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  exclude-result-prefixes="exslt mcr mcrid mcrmodsclass mcrpages mcrxml xlink">

  <xsl:include href="resource:xsl/copynodes.xsl" />
  <xsl:include href="resource:xsl/editor/mods-node-utils.xsl" />
  <xsl:include href="resource:xsl/mods-utils.xsl" />
  <xsl:include href="resource:xsl/coreFunctions.xsl" />

  <xsl:param name="MIR.PPN.DatabaseList" select="'gvk'" />
  <xsl:param name="MCR.Metadata.ObjectID.NumberPattern" select="00000000" />

  <xsl:template match="mycoreobject/structure">
    <xsl:copy>
      <xsl:variable name="hostItem"
        select="../metadata/def.modsContainer/modsContainer/mods:mods/mods:relatedItem[@type='host'
                    and @xlink:href and mcrid:isValid(@xlink:href)
                    and not($MCR.Metadata.ObjectID.NumberPattern=substring(@xlink:href, string-length(@xlink:href) - string-length($MCR.Metadata.ObjectID.NumberPattern) + 1))]/@xlink:href" />
      <xsl:if test="$hostItem">
        <parents class="MCRMetaLinkID">
          <parent xlink:href="{$hostItem}" xlink:type="locator" inherited="0" />
        </parents>
      </xsl:if>
      <xsl:apply-templates />
    </xsl:copy>
  </xsl:template>

  <xsl:template match="mycoreobject[not(structure)]">
    <xsl:copy>
      <xsl:apply-templates select="@*" />
      <xsl:variable name="hostItem"
        select="metadata/def.modsContainer/modsContainer/mods:mods/mods:relatedItem[@type='host'
                    and @xlink:href and mcrid:isValid(@xlink:href)
                    and not($MCR.Metadata.ObjectID.NumberPattern=substring(@xlink:href, string-length(@xlink:href) - string-length($MCR.Metadata.ObjectID.NumberPattern) + 1))]/@xlink:href" />
      <xsl:if test="$hostItem">
        <structure>
          <parents class="MCRMetaLinkID">
            <parent xlink:href="{$hostItem}" xlink:type="locator" inherited="0" />
          </parents>
        </structure>
      </xsl:if>
      <xsl:apply-templates select="node()" />
    </xsl:copy>
  </xsl:template>
  <!--
  <xsl:template match="mods:titleInfo|mods:abstract">
    <xsl:choose>
      <xsl:when test="mcrxml:isHtml(mods:nonSort/text()) or mcrxml:isHtml(mods:title/text()) or mcrxml:isHtml(mods:subTitle/text()) or mcrxml:isHtml(text())">
        <xsl:variable name="altRepGroup" select="generate-id(.)" />
        <xsl:copy>
          <xsl:attribute name="altRepGroup">
            <xsl:value-of select="$altRepGroup" />
          </xsl:attribute>
          <xsl:apply-templates select="@*" />
          <xsl:apply-templates mode="asPlainTextNode" />
        </xsl:copy>
        <xsl:element name="{name(.)}" namespace="{namespace-uri()}">
          <xsl:variable name="content">
            <xsl:apply-templates select="." mode="asXmlNode">
              <xsl:with-param name="ns" select="''" />
              <xsl:with-param name="serialize" select="false()" />
              <xsl:with-param name="levels">
                <xsl:choose>
                  <xsl:when test="name() = 'mods:titleInfo'">
                    <xsl:value-of select="2" />
                  </xsl:when>
                  <xsl:otherwise>
                    <xsl:value-of select="1" />
                  </xsl:otherwise>
                </xsl:choose>
              </xsl:with-param>
            </xsl:apply-templates>
          </xsl:variable>
          <xsl:attribute name="altRepGroup">
            <xsl:value-of select="$altRepGroup" />
          </xsl:attribute>
          <xsl:attribute name="altFormat">
            <xsl:value-of select="mcrdataurl:build($content, 'base64', 'text/xml', 'utf-8')" />
          </xsl:attribute>
          <xsl:attribute name="contentType">
            <xsl:value-of select="'text/xml'" />
          </xsl:attribute>
          <xsl:apply-templates select="@*" />
        </xsl:element>
      </xsl:when>
      <xsl:otherwise>
        <xsl:copy>
          <xsl:apply-templates select="@*" />
          <xsl:apply-templates />
        </xsl:copy>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  -->

  <!-- convert date-time with timezone to UTC -->
  <xsl:template match="mods:*[@encoding='w3cdtf' and contains(text(), 'T') and substring(text(), string-length(text())) != 'Z']">
    <xsl:copy>
      <xsl:copy-of select="@*" />
      <xsl:variable name="apos">'</xsl:variable>
      <xsl:variable name="w3ctf-date-time" select="text()" />
      <xsl:variable name="simple-date-format" select="concat('yyyy-MM-dd',$apos,'T',$apos,'HH:mm:ssX')" />
      <xsl:variable name="iso-8601-format" select="'UUUU-MM-DDThh:mm:ssTZD'" />
      <xsl:value-of select="mcrxml:getISODate($w3ctf-date-time, $simple-date-format, $iso-8601-format)" />
    </xsl:copy>
  </xsl:template>

  <!-- create value URI using valueURIxEditor and authorityURI -->
  <xsl:template match="@valueURIxEditor">
    <xsl:choose>
      <xsl:when test="starts-with(., 'http://d-nb.info/gnd/')">
        <mods:nameIdentifier type="gnd" typeURI="http://d-nb.info/gnd/">
          <xsl:value-of select="substring-after(., 'http://d-nb.info/gnd/')" />
        </mods:nameIdentifier>
      </xsl:when>
      <xsl:when test="starts-with(., 'http://www.viaf.org/')">
        <mods:nameIdentifier type="viaf" typeURI="http://www.viaf.org/">
          <xsl:value-of select="substring-after(., 'http://www.viaf.org/')" />
        </mods:nameIdentifier>
      </xsl:when>
      <xsl:when test="starts-with(../@authorityURI, 'http://d-nb.info/gnd/')">
        <xsl:attribute name="valueURI">
          <xsl:value-of select="concat(../@authorityURI,.)" />
        </xsl:attribute>
      </xsl:when>
      <xsl:otherwise>
        <xsl:attribute name="valueURI">
          <xsl:value-of select="concat(../@authorityURI,'#',.)" />
        </xsl:attribute>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="mods:nameIdentifier[@type=preceding-sibling::mods:nameIdentifier/@type or contains(../@valueURIxEditor, @type)]">
    <xsl:message>
      <xsl:value-of select="concat('Skipping ',@type,' identifier: ',.,' due to previous declaration.')" />
    </xsl:message>
  </xsl:template>

  <xsl:template match="mods:nameIdentifier">
    <xsl:variable name="type" select="@type"></xsl:variable>
    <xsl:variable name="curi"
      select="document(concat('classification:metadata:all:children:','nameIdentifier',':',$type))/mycoreclass/categories/category[@ID=$type]/label[@xml:lang='x-uri']/@text" />

    <!-- if no typeURI defined in classification, we used the default -->
    <xsl:variable name="uri">
      <xsl:choose>
        <xsl:when test="string-length($curi) = 0">
          <xsl:value-of select="@typeURI" />
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="$curi" />
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <mods:nameIdentifier type="{$type}">
      <xsl:if test="string-length($uri) &gt; 0">
        <xsl:attribute name="typeURI">
          <xsl:value-of select="$uri" />
        </xsl:attribute>
      </xsl:if>

      <xsl:value-of select="." />
    </mods:nameIdentifier>
  </xsl:template>

  <xsl:template match="mods:affiliation">
    <xsl:variable name="fullValue" select="."/>

    <xsl:choose>
      <!-- Case when affiliation contains a ROR URL -->
      <xsl:when test="contains($fullValue, 'ror.org/')">
        <!-- Extract name (everything before the opening parenthesis of the ROR URL) -->
        <xsl:variable name="beforeROR" select="substring-before($fullValue, '(http')"/>
        <xsl:variable name="name">
          <xsl:choose>
            <xsl:when test="$beforeROR != ''">
              <xsl:value-of select="normalize-space($beforeROR)"/>
            </xsl:when>
            <xsl:otherwise>
              <!-- If there's nothing before the ROR URL, use the part after as name -->
              <xsl:value-of select="normalize-space(substring-before($fullValue, ')'))"/>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:variable>

        <!-- Extract ROR URL -->
        <xsl:variable name="rorURL">
          <xsl:call-template name="extractRORURL">
            <xsl:with-param name="text" select="$fullValue"/>
          </xsl:call-template>
        </xsl:variable>

        <mods:affiliation authorityURI="https://ror.org/">
          <xsl:if test="$rorURL != ''">
            <xsl:attribute name="valueURI">
              <xsl:value-of select="$rorURL"/>
            </xsl:attribute>
          </xsl:if>
          <xsl:value-of select="$name"/>
        </mods:affiliation>
      </xsl:when>

      <!-- Case when affiliation is just plain text without ROR URL -->
      <xsl:otherwise>
        <mods:affiliation>
          <xsl:value-of select="$fullValue"/>
        </mods:affiliation>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <!-- Helper template to extract ROR URL -->
  <xsl:template name="extractRORURL">
    <xsl:param name="text"/>

    <!-- Find the start of http(s) -->
    <xsl:variable name="afterOpenParen" select="substring-after($text, '(')"/>
    <xsl:variable name="httpPos">
      <xsl:choose>
        <xsl:when test="contains($afterOpenParen, 'http://ror.org/')">
          <xsl:value-of select="'http://ror.org/'"/>
        </xsl:when>
        <xsl:when test="contains($afterOpenParen, 'https://ror.org/')">
          <xsl:value-of select="'https://ror.org/'"/>
        </xsl:when>
        <xsl:otherwise/>
      </xsl:choose>
    </xsl:variable>

    <xsl:if test="$httpPos != ''">
      <xsl:variable name="afterHTTP" select="substring-after($afterOpenParen, $httpPos)"/>
      <xsl:variable name="rorID" select="substring-before($afterHTTP, ')')"/>
      <xsl:if test="$rorID != ''">
        <xsl:value-of select="concat($httpPos, $rorID)"/>
      </xsl:if>
    </xsl:if>
  </xsl:template>

  <!-- Copy content of mods:accessCondtition to mods:classification to enable classification support (see MIR-161) -->
  <xsl:template match="mods:accessCondition[@type='restriction on access'][contains(@xlink:href,'mir_access')]">
    <mods:accessCondition type="restriction on access">
      <xsl:attribute name="xlink:href">
        <xsl:value-of select="concat(@xlink:href, '#', .)" />
      </xsl:attribute>
    </mods:accessCondition>
  </xsl:template>

  <xsl:template match="mods:accessCondition[@type='use and reproduction']">
    <mods:accessCondition type="use and reproduction">
      <xsl:attribute name="xlink:href">
        <xsl:choose>
          <xsl:when test="@xlink:href">
            <xsl:value-of select="concat(@xlink:href, '#', .)" />
          </xsl:when>
          <xsl:otherwise>
            <xsl:variable name="mir_licenses_uri" select="document('classification:metadata:-1:children:mir_licenses')/mycoreclass/label[@xml:lang='x-uri']/@text" />
            <xsl:value-of select="concat($mir_licenses_uri,'#', .)" />
          </xsl:otherwise>
        </xsl:choose>
      </xsl:attribute>
    </mods:accessCondition>
  </xsl:template>

  <xsl:template match="@mcr:categId" />
  <xsl:template match="*[@mcr:categId]">
    <xsl:element name="{name()}">
      <xsl:variable name="classNodes" select="mcrmodsclass:getClassNodes(.)" />
      <xsl:apply-templates select='$classNodes/@*|@*|node()|$classNodes/node()' />
    </xsl:element>
  </xsl:template>

  <xsl:template match="mods:openAireID">
    <mods:identifier type="open-aire">
      <xsl:value-of select="." />
    </mods:identifier>
  </xsl:template>

  <xsl:template match="mods:name/mods:displayForm">
    <xsl:variable name="etalShortcut">
      |etal|et al|et.al.|u.a.|ua|etc|u.s.w.|usw|...
    </xsl:variable>
    <xsl:choose>
      <xsl:when test="contains($etalShortcut,.)">
        <mods:etal />
      </xsl:when>
      <xsl:otherwise>
        <xsl:copy-of select="." />
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="mods:name">
    <xsl:copy>
      <xsl:copy-of select="@*[name()!='simpleEditor' and name()!='valueURIxEditor']" />
      <xsl:if test="@valueURIxEditor">
        <xsl:attribute name="valueURI">
          <xsl:value-of select="concat(@authorityURI,'#',@valueURIxEditor)" />
        </xsl:attribute>
      </xsl:if>
      <xsl:choose>
        <xsl:when test="@simpleEditor">
          <xsl:apply-templates select="node()[name()!='mods:namePart']" />
        </xsl:when>
        <xsl:otherwise>
          <xsl:apply-templates />
        </xsl:otherwise>
      </xsl:choose>
      <xsl:if test="(not(mods:namePart[@type='family']) or @simpleEditor)  and mods:displayForm and @type='personal'">
        <xsl:call-template name="mods.seperateName">
          <xsl:with-param name="displayForm" select="mods:displayForm" />
        </xsl:call-template>
      </xsl:if>
    </xsl:copy>
  </xsl:template>

  <xsl:template match="mods:identifier[@type='ppn']">
    <xsl:variable name="database">
      <xsl:choose>
        <xsl:when test="@transliteration and string-length(@transliteration) &gt; 0">
          <xsl:value-of select="@transliteration" />
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="$MIR.PPN.DatabaseList" />
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <mods:identifier type="uri">
      <xsl:value-of select="concat('http://uri.gbv.de/document/', $database, ':ppn:',text())" />
    </mods:identifier>
  </xsl:template>

  <xsl:template match="mods:identifierManaged">
    <mods:identifier>
      <xsl:apply-templates select="@*|node()" />
    </mods:identifier>
  </xsl:template>

  <!-- In editor, all variants of page numbers are edited in a single text field -->
  <xsl:template match="mods:part/mods:extent[@unit='pages']">
    <xsl:copy-of select="mcrpages:buildExtentPagesNodeSet(mods:list/text())" />
  </xsl:template>

  <xsl:template match="mods:subject/mods:topic[contains(text(), ';')]">
    <xsl:variable name="topic">
      <xsl:call-template name="Tokenizer"><!-- use split function from mycore-base/coreFunctions.xsl -->
        <xsl:with-param name="string" select="." />
        <xsl:with-param name="delimiter" select="';'" />
      </xsl:call-template>
    </xsl:variable>
    <xsl:for-each select="exslt:node-set($topic)/token">
      <xsl:if test="mcrxml:trim(.) != ''">
        <mods:topic>
          <xsl:value-of select="." />
        </mods:topic>
      </xsl:if>
    </xsl:for-each>
  </xsl:template>

  <xsl:template match="mods:location">
    <xsl:copy>
      <xsl:copy-of select="@*" />
      <xsl:apply-templates select="mods:physicalLocation" />
      <xsl:apply-templates select="mods:shelfLocator" />
      <xsl:apply-templates select="mods:url" />
      <xsl:apply-templates select="mods:holdingSimple" />
      <xsl:apply-templates select="mods:holdingExternal" />
    </xsl:copy>
  </xsl:template>

</xsl:stylesheet>
