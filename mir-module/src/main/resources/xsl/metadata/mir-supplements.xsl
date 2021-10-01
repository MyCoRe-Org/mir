<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="3.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:i18n="xalan://org.mycore.services.i18n.MCRTranslation"
                xmlns:mods="http://www.loc.gov/mods/v3" exclude-result-prefixes="i18n mods">

  <xsl:import href="xslImport:modsmeta:metadata/mir-supplements.xsl"/>

  <xsl:template match="/">
    <xsl:variable name="mods" select="mycoreobject/metadata/def.modsContainer/modsContainer/mods:mods"/>

    <xsl:if test="$mods/mods:relatedItem[not(@type) and @otherType='supplement']">
      <div id="mir-supplements">
        <div class="detail_block">
          <h3>
            <xsl:value-of select="i18n:translate('mir.metadata.supplements')"/>
          </h3>
          <ul class="mir-toc-section-list">
            <xsl:for-each select="$mods/mods:relatedItem[not(@type) and @otherType='supplement']">
              <li class="mir-toc-section-entry">
                <div>
                  <div class="mir-toc-section-page float-right">
                    <xsl:variable name="type" select="substring-after(mods:genre/@valueURI,'#')"/>
                    <xsl:variable name="typeUri" select="concat('classification:metadata:0:children:mir_supplementTypes:',$type)"/>
                    <xsl:variable name="typeLabel" select="document($typeUri)//category/label[@xml:lang=$CurrentLang]/@text"/>
                    <xsl:value-of select="concat('(',$typeLabel,')')"/>
                  </div>
                  <h4 class="mir-toc-section-title">
                    <a target="_blank">
                      <xsl:attribute name="href">
                        <xsl:value-of select="mods:location/mods:url[1]"/>
                      </xsl:attribute>
                      <xsl:value-of select="mods:titleInfo/mods:title"/>
                      <xsl:if test="mods:titleInfo/mods:subTitle">
                        <xsl:text> : </xsl:text>
                        <xsl:value-of select="mods:titleInfo/mods:subTitle"/>
                      </xsl:if>
                    </a>
                  </h4>
                  <div class="mir-toc-section-author">
                    <xsl:value-of select="mods:name[@type='personal'][1]/mods:displayForm"/>
                    <xsl:for-each select="mods:name[@type='personal'][position()!=1]/mods:displayForm">
                      <xsl:text>; </xsl:text>
                      <xsl:value-of select="."/>
                    </xsl:for-each>
                  </div>
                </div>
              </li>
            </xsl:for-each>
          </ul>
        </div>
      </div>
    </xsl:if>

    <xsl:apply-imports/>
  </xsl:template>

</xsl:stylesheet>
