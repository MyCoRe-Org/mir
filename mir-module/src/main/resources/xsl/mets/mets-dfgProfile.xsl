<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xlink="http://www.w3.org/1999/xlink"
                xmlns:mets="http://www.loc.gov/METS/"
                xmlns:mods="http://www.loc.gov/mods/v3" xmlns:xalan="http://xml.apache.org/xalan"
                xmlns:mcr="xalan://org.mycore.common.xml.MCRXMLFunctions"
                exclude-result-prefixes="mcr" version="1.0">
  <xsl:include href="resource:xsl/mets/mets-iview.xsl" />
  <xsl:include href="resource:xsl/mets/mets-amd.xsl" />
  <xsl:include href="resource:xsl/mods-enhancer.xsl" />

  <xsl:output method="xml" encoding="utf-8" />
  <xsl:param name="MCR.Module-iview2.SupportedContentTypes" />
  <xsl:param name="ServletsBaseURL" />
  <xsl:param name="WebApplicationBaseURL" />
  <xsl:param name="derivateID" />
  <xsl:param name="objectID" />

  <xsl:variable name="sourcedoc" select="document(concat('mcrobject:',$objectID))" />

  <xsl:template match="/mycoreobject" priority="0" mode="metsmeta" xmlns:mods="http://www.loc.gov/mods/v3">
        <xsl:apply-templates mode="mods2mods" />
  </xsl:template>

  <xsl:template match="mycoreobject" priority="0" mode="fallBackEntity"
                xmlns:mir="http://www.mycore.de/mir/ns/mods-entities">
    <!-- TODO: add configurable template
    <mir:entity type="owner" xlink:type="extended" xlink:title="xxx">
      <mir:site xlink:type="locator" xlink:href="#" />
      <mir:logo xlink:type="resource" xlink:href="#" />
      <mir:full-logo xlink:type="resource" xlink:href="#" />
    </mir:entity> -->
  </xsl:template>

  <xsl:template match="mycoreobject" priority="0" mode="ownerEntity">
    <xsl:apply-templates select="." mode="fallbackEntity" />
  </xsl:template>

  <xsl:template match="mycoreobject" priority="0" mode="sponsorEntity">
    <xsl:comment>
      no sponsor defined
    </xsl:comment>
  </xsl:template>

  <xsl:template match="mycoreobject" priority="0" mode="partnerEntity">
    <xsl:comment>
      no partner defined
    </xsl:comment>
  </xsl:template>

  <xsl:template match="mycoreobject" priority="0" mode="entities">
    <xsl:apply-templates mode="ownerEntity" select="." />
    <xsl:apply-templates mode="sponsorEntity" select="." />
    <xsl:apply-templates mode="partnerEntity" select="." />
  </xsl:template>

  <xsl:template match="mets:mets">
    <mets:mets>
      <xsl:if test="not(mets:dmdSec)">
        <xsl:variable name="emptyDMDSec">
          <mets:dmdSec ID="dmd_{$derivateID}"/>
        </xsl:variable>
        <xsl:apply-templates select="xalan:nodeset($emptyDMDSec)" />
      </xsl:if>
      <xsl:if test="not(mets:amdSec)">
        <xsl:variable name="emptryAMDSec">
          <mets:amdSec />
        </xsl:variable>
        <xsl:apply-templates select="xalan:nodeset($emptryAMDSec)" />
      </xsl:if>
      <xsl:apply-templates />
    </mets:mets>
  </xsl:template>

  <xsl:template match="mets:dmdSec">
    <mets:dmdSec ID="dmd_{$derivateID}">
      <mets:mdWrap MDTYPE="MODS">
        <mets:xmlData>
            <xsl:apply-templates mode="metsmeta" select="$sourcedoc/mycoreobject" />
            <!-- TODO: add configurable template
            <mods:extension>
              <mir:entities xmlns:mir="http://www.mycore.de/mir/ns/mods-entities">
                <mir:entity type="operator" xlink:type="extended"
                              xlink:title="xxx">
                  <mir:site xlink:type="locator" xlink:href="#" />
                  <mir:logo xlink:type="resource" xlink:href="{$logoBaseUrl}xxx.svg" />
                  <mir:full-logo xlink:type="resource" xlink:href="{$logoBaseUrl}xxx.svg" />
                </mir:entity>
                <xsl:apply-templates mode="entities" select="$sourcedoc/mycoreobject" />
              </mir:entities>
            </mods:extension>
            -->
        </mets:xmlData>
      </mets:mdWrap>
    </mets:dmdSec>
  </xsl:template>

  <xsl:template match="mets:amdSec">
    <xsl:call-template name="amdSec">
      <xsl:with-param name="derobject" select="$derivateID" />
    </xsl:call-template>
  </xsl:template>

</xsl:stylesheet>
