<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:mods="http://www.loc.gov/mods/v3"
  xmlns:mcrxsl="xalan://org.mycore.common.xml.MCRXMLFunctions" exclude-result-prefixes="mods mcrxsl">
  <xsl:import href="xslImport:solr-document:mir-solr.xsl" />

  <xsl:template match="mycoreobject[contains(@ID,'_mods_')]">
    <xsl:param name="foo" />
    <xsl:apply-imports />
    <!-- fields from mycore-mods -->
    <xsl:apply-templates select="metadata/def.modsContainer/modsContainer/mods:mods"/>
    <field name="hasFiles">
      <xsl:value-of select="count(structure/derobjects/derobject)&gt;0" />
    </field>
  </xsl:template>

  <xsl:template match="mods:mods" mode="mir">
    <xsl:apply-imports/>
    <xsl:for-each select="mods:name[@type='corporate' and @authorityURI]">
      <xsl:variable name="uri" xmlns:mcrmods="xalan://org.mycore.mods.MCRMODSClassificationSupport" select="mcrmods:getClassCategParentLink(.)" />
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
  </xsl:template>
</xsl:stylesheet>