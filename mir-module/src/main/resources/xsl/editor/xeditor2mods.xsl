<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:mcr="http://www.mycore.org/" xmlns:xlink="http://www.w3.org/1999/xlink"
  xmlns:mods="http://www.loc.gov/mods/v3" xmlns:mcrmods="xalan://org.mycore.mods.classification.MCRMODSClassificationSupport" xmlns:mcrxml="xalan://org.mycore.common.xml.MCRXMLFunctions"
  xmlns:mcrdataurl="xalan://org.mycore.datamodel.common.MCRDataURL" xmlns:exslt="http://exslt.org/common" exclude-result-prefixes="mcrmods xlink mcr mcrxml mcrdataurl exslt" version="1.0"
>

  <xsl:include href="copynodes.xsl" />
  <xsl:include href="editor/mods-node-utils.xsl" />
  <xsl:include href="mods-utils.xsl"/>
  <xsl:include href="coreFunctions.xsl"/>

  <xsl:param name="MIR.PPN.DatabaseList" select="'gvk'" />

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
        <xsl:element name="{name(.)}">
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
    <mods:nameIdentifier type="{$type}" typeURI="{$uri}">
      <xsl:value-of select="." />
    </mods:nameIdentifier>
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
      <xsl:variable name="classNodes" select="mcrmods:getClassNodes(.)" />
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

  <xsl:template match="mods:name[@type='personal']">
    <xsl:copy>
      <xsl:copy-of select="@*" />
      <xsl:apply-templates />
      <xsl:if test="not(mods:namePart[@type='family']) and mods:displayForm">
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
          <xsl:value-of select="@transliteration"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="$MIR.PPN.DatabaseList"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <mods:identifier type="uri">
      <xsl:value-of select="concat('http://uri.gbv.de/document/', $database, ':ppn:', text())" />
    </mods:identifier>
  </xsl:template>

  <!-- In editor, all variants of page numbers are edited in a single text field -->
  <xsl:template match="mods:part/mods:extent[@unit='pages']" xmlns:pages="xalan://org.mycore.mods.MCRMODSPagesHelper">
    <xsl:copy-of select="pages:buildExtentPagesNodeSet(mods:list/text())" />
  </xsl:template>

  <xsl:template match="mods:subject/mods:topic">
    <xsl:variable name="topic">
      <xsl:call-template name="Tokenizer"><!-- use split function from mycore-base/coreFunctions.xsl -->
        <xsl:with-param name="string" select="." />
        <xsl:with-param name="delimiter" select="';'" />
      </xsl:call-template>
    </xsl:variable>
    <xsl:for-each select="exslt:node-set($topic)/token">
      <xsl:if test="mcrxml:trim(.) != ''">
        <mods:topic>
          <xsl:value-of select="."/>
        </mods:topic>
      </xsl:if>
    </xsl:for-each>
  </xsl:template>

</xsl:stylesheet>