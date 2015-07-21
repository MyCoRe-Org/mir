<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:mcrmods="xalan://org.mycore.mods.classification.MCRMODSClassificationSupport"
  xmlns:mods="http://www.loc.gov/mods/v3">
  <xsl:include href="copynodes.xsl" />
  <xsl:param name="MCR.Metadata.Service.State.Category.Default" select="'submitted'" />
  <xsl:variable name="id" select="/mycoreobject/@ID" />
  <xsl:variable name="oldstatus"
    select="mcrmods:getClassCategLink(/mycoreobject/metadata/def.modsContainer/modsContainer/mods:mods/mods:classification[@authorityURI='http://www.mycore.org/classifications/mir_status'])" />

  <xsl:template match="/mycoreobject/service/servstates[string-length($oldstatus)&gt;0]">
    <xsl:message>
      <xsl:value-of select="concat('overwrite old value of classification status for ',$id)" />
    </xsl:message>
  </xsl:template>
  <xsl:template match="mods:classification[@authorityURI='http://www.mycore.org/classifications/mir_status']" />
  <xsl:template match="service">
    <xsl:copy>
      <xsl:apply-templates />
      <xsl:if test="not(servstates) or string-length($oldstatus) &gt; 0">
        <servstates class="MCRMetaClassification">
          <servstate inherited="0" classid="state">
            <xsl:attribute name="categid">
            <xsl:choose>
              <xsl:when test="string-length($oldstatus)&gt;0">
                <xsl:variable name="state" select="document($oldstatus)//category[1]" />
                <xsl:message>
                  <xsl:value-of select="concat('Setting state of ',$id,' to ',$state/@ID,'.')" />
                </xsl:message>
                <xsl:value-of select="$state/@ID" />
              </xsl:when>
              <xsl:when test="not(servstates)">
                <xsl:variable name="default" select="$MCR.Metadata.Service.State.Category.Default" />
                <xsl:message>
                  <xsl:value-of select="concat('Setting state of ',$id,' to default value ',$default,'.')" />
                </xsl:message>
                <xsl:value-of select="$default" />
              </xsl:when>
            </xsl:choose>
            </xsl:attribute>
          </servstate>
        </servstates>
      </xsl:if>
    </xsl:copy>
  </xsl:template>
</xsl:stylesheet>