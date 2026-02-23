<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0"
  xmlns:mcri18n="xalan://org.mycore.services.i18n.MCRTranslation"
  xmlns:mcrmodsclass="xalan://org.mycore.mods.classification.MCRMODSClassificationSupport" 
  xmlns:mcrxml="xalan://org.mycore.common.xml.MCRXMLFunctions"
  xmlns:mods="http://www.loc.gov/mods/v3"
  xmlns:xalan="http://xml.apache.org/xalan"
  xmlns:xlink="http://www.w3.org/1999/xlink"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  exclude-result-prefixes="mcrmodsclass mods xlink">

  <xsl:import href="xslImport:solr-document:mir-solr.xsl" />
  <xsl:include href="mods-utils.xsl" />

  <xsl:template match="mycoreobject[contains(@ID,'_mods_')]">
    <xsl:variable name="status" select="mcrxml:isInCategory(@ID,'state:published')" />
    <xsl:apply-imports />
    <!-- fields from mycore-mods -->
    <xsl:apply-templates select="metadata/def.modsContainer/modsContainer/mods:mods" mode="mir">
      <xsl:with-param name="status" select="$status" />
    </xsl:apply-templates>
    <field name="hasFiles">
      <xsl:value-of select="count(structure/derobjects/derobject)&gt;0" />
    </field>
  </xsl:template>

  <xsl:template match="mods:mods" mode="mir">
    <xsl:param name="status" />
    <xsl:for-each select="mods:name[@type='corporate' and @authorityURI]">
      <xsl:variable name="uri" select="mcrmodsclass:getClassCategParentLink(.)" />
      <xsl:if test="string-length($uri) &gt; 0">
        <xsl:variable name="classdoc" select="document($uri)" />
        <xsl:for-each select="$classdoc//category">
          <field name="corporate">
            <xsl:value-of select="@ID" />
          </field>
        </xsl:for-each>
      </xsl:if>
    </xsl:for-each>
    <xsl:for-each select="mods:extension/year/impactFactor">
      <xsl:value-of select="." />
    </xsl:for-each>
    <xsl:for-each select="mods:identifier[@type='isbn']">
      <xsl:variable name="isbn" select="." />
      <field name="isbn">
        <xsl:value-of select="$isbn" />
      </field>
      <xsl:variable name="isbnClear" select="translate($isbn,'-','')" />
<!--       <xsl:message> -->
<!--         ISBN   : <xsl:value-of select="$isbn"/> -->
<!--         cleared: <xsl:value-of select="$isbnClear"/> -->
<!--       </xsl:message> -->
      <xsl:if test="$isbn != $isbnClear">
        <field name="isbn">
          <xsl:value-of select="$isbnClear" />
        </field>
      </xsl:if>
      <xsl:if test="string-length($isbnClear)&gt; 10 and starts-with($isbnClear,'978')">
        <xsl:variable name="isbn10sum">
          <xsl:value-of
            select="
            (number(substring($isbnClear,4,1))*1+
            number(substring($isbnClear,5,1))*2+
            number(substring($isbnClear,6,1))*3+
            number(substring($isbnClear,7,1))*4+
            number(substring($isbnClear,8,1))*5+
            number(substring($isbnClear,9,1))*6+
            number(substring($isbnClear,10,1))*7+
            number(substring($isbnClear,11,1))*8+
            number(substring($isbnClear,12,1))*9) mod 11
          " />
        </xsl:variable>
        <xsl:variable name="isbn10checksum">
          <xsl:choose>
            <xsl:when test="$isbn10sum = 10">
              <xsl:value-of select="'X'" />
            </xsl:when>
            <xsl:otherwise>
              <xsl:value-of select="string($isbn10sum)" />
            </xsl:otherwise>
          </xsl:choose>
        </xsl:variable>
        <xsl:variable name="isbn10base">
          <xsl:choose>
            <xsl:when test="substring($isbn,4,1)='-'">
              <xsl:value-of select="substring($isbn,5,string-length($isbn)-5)" />
            </xsl:when>
            <xsl:otherwise>
              <xsl:value-of select="substring($isbn,4,string-length($isbn)-4)" />
            </xsl:otherwise>
          </xsl:choose>
        </xsl:variable>
        <xsl:variable name="isbn10" select="concat($isbn10base,$isbn10checksum)" />
        <field name="isbn">
          <xsl:value-of select="$isbn10" />
        </field>
        <xsl:variable name="isbn10Clear" select="translate($isbn10,'-','')" />
<!--         <xsl:message> -->
<!--           ISBN10   : <xsl:value-of select="$isbn10"/> -->
<!--           cleared: <xsl:value-of select="$isbn10Clear"/> -->
<!--         </xsl:message> -->
        <xsl:if test="$isbn10 != $isbn10Clear">
          <field name="isbn">
            <xsl:value-of select="$isbn10Clear" />
          </field>
        </xsl:if>
      </xsl:if>
    </xsl:for-each>
    <xsl:for-each select=".//mods:name[@type='personal']">
      <!-- person index name entry -->
      <xsl:variable name="pindexname">
        <xsl:apply-templates select="." mode="queryableNameString" />
        <xsl:variable name="nameIds">
          <xsl:call-template name="getNameIdentifiers">
            <xsl:with-param name="entity" select="." />
          </xsl:call-template>
        </xsl:variable>
        <xsl:variable name="nameIdentifier" select="xalan:nodeset($nameIds)/nameIdentifier[1]" />
        <xsl:if test="count($nameIdentifier) &gt; 0">
          <xsl:text>:</xsl:text>
          <xsl:value-of select="$nameIdentifier/@type" />
          <xsl:text>:</xsl:text>
          <xsl:value-of select="$nameIdentifier/@id" />
        </xsl:if>
      </xsl:variable>
      <field name="mods.pindexname">
        <xsl:value-of select="normalize-space($pindexname)" />
      </field>
      <xsl:if test="$status">
        <field name="mods.pindexname.published">
          <xsl:value-of select="normalize-space($pindexname)" />
        </field>
      </xsl:if>
    </xsl:for-each>
    <xsl:for-each select=".//mods:name[@type='conference']">
      <xsl:variable name="conference">
        <xsl:for-each select="mods:displayForm | mods:namePart | text()">
          <xsl:value-of select="concat(' ',.)" />
        </xsl:for-each>
      </xsl:variable>
      <field name="mods.name.conference">
        <xsl:value-of select="normalize-space($conference)" />
      </field>
    </xsl:for-each>
    <xsl:for-each select="mods:name[@type='personal' or 'corporate']">
      <field name="mods.nameByRole.{@type}.{mods:role/mods:roleTerm[@type='code']}">
        <xsl:apply-templates select="." mode="nameString" />
        <xsl:variable name="nameIds">
          <xsl:call-template name="getNameIdentifiers">
            <xsl:with-param name="entity" select="." />
          </xsl:call-template>
        </xsl:variable>
        <xsl:variable name="nameIdentifier" select="xalan:nodeset($nameIds)/nameIdentifier[1]" />
        <xsl:if test="count($nameIdentifier) &gt; 0">
          <xsl:text>:</xsl:text>
          <xsl:value-of select="$nameIdentifier/@type" />
          <xsl:text>:</xsl:text>
          <xsl:value-of select="$nameIdentifier/@id" />
        </xsl:if>
      </field>
    </xsl:for-each>
    <xsl:for-each select="mods:abstract[not(@altFormat)][1]">
      <field name="mods.abstract.result">
        <xsl:value-of select="mcrxml:shortenText(text(),300)" />
      </field>
    </xsl:for-each>
    <xsl:for-each select="mods:abstract[not(@altFormat)][@xml:lang]">
      <field name="mods.abstract.result.{@xml:lang}">
        <xsl:value-of select="mcrxml:shortenText(text(),300)" />
      </field>
    </xsl:for-each>
    <xsl:for-each select="mods:relatedItem[@xlink:href]">
      <field name="mods.relatedItem">
        <xsl:value-of select="@xlink:href" />
        |
        <xsl:choose>
          <xsl:when test="@type">
            <xsl:value-of select="@type" />
          </xsl:when>
          <xsl:when test="@otherType">
            <xsl:value-of select="@otherType" />
          </xsl:when>
        </xsl:choose>
      </field>
      <xsl:if test="mods:part/@order">
        <field name="mods.part.order.{@xlink:href}">
          <xsl:value-of select="mods:part/@order" />
        </field>
      </xsl:if>
      <xsl:if test="@type='host' and mods:part/mods:detail[@type='volume']">
        <field name="mods.part.{@xlink:href}">
          <xsl:choose>
            <xsl:when test="mods:part/mods:detail[@type='issue']/mods:number">
              <xsl:variable name="issue">
                <xsl:choose>
                  <xsl:when test="mods:part/mods:detail[@type='issue']/mods:caption">
                    <xsl:value-of select="mods:part/mods:detail[@type='issue']/mods:caption" />
                  </xsl:when>
                  <xsl:otherwise>
                    <xsl:value-of select="mcri18n:translate('component.mods.metaData.dictionary.issue')" />
                  </xsl:otherwise>
                </xsl:choose>
              </xsl:variable>
              <xsl:value-of
                select="concat(normalize-space(mods:part/mods:detail[@type='volume']),
                                          ', ',
                                          $issue,
                                          ' ',
                                          normalize-space(mods:part/mods:detail[@type='issue']/mods:number))" />
            </xsl:when>
            <xsl:otherwise>
              <xsl:value-of select="normalize-space(mods:part/mods:detail[@type='volume'])" />
            </xsl:otherwise>
          </xsl:choose>
        </field>
      </xsl:if>
      <xsl:if test="@type='series' and mods:part/mods:detail[@type='volume']">
        <field name="mods.part.{@xlink:href}">
          <xsl:value-of select="normalize-space(mods:part/mods:detail[@type='volume']/mods:number)" />
        </field>
      </xsl:if>
    </xsl:for-each>
  </xsl:template>

</xsl:stylesheet>
