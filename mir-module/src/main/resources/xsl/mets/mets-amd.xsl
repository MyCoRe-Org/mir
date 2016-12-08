<?xml version="1.0" encoding="UTF-8"?>
<!-- ============================================== -->
<!-- $Revision$ $Date$ -->
<!-- ============================================== -->
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:xlink="http://www.w3.org/1999/xlink"
                xmlns:mcr="http://www.mycore.org/" xmlns:acl="xalan://org.mycore.access.MCRAccessManager"
                xmlns:mets="http://www.loc.gov/METS/"
                xmlns:mods="http://www.loc.gov/mods/v3" xmlns:i18n="xalan://org.mycore.services.i18n.MCRTranslation"
                xmlns:xalan="http://xml.apache.org/xalan"
                xmlns:mcrxml="xalan://org.mycore.common.xml.MCRXMLFunctions"
                xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
                exclude-result-prefixes="mcr xalan i18n acl mcrxml">

  <xsl:param name="WebApplicationBaseURL" />
  <xsl:param name="objectID" />
  <xsl:param name="license" select="'CC-BY-NC-SA'" />
  <xsl:param name="MIR.DFGViewer.DV.Owner" select="''" />
  <xsl:param name="MIR.DFGViewer.DV.OwnerLogo" select="''" />
  <xsl:param name="MIR.DFGViewer.DV.OwnerSiteURL" select="''" />
  <xsl:param name="MIR.DFGViewer.DV.OPAC.CATALOG.URL" select="''" />

  <xsl:template name="amdSec">
    <xsl:param name="mcrobject" />
    <xsl:param name="derobject" />

    <xsl:variable name="sectionID">
      <xsl:choose>
        <xsl:when test="$mcrobject">
          <xsl:value-of select="$mcrobject" />
        </xsl:when>
        <xsl:when test="$derobject">
          <xsl:value-of select="$derobject" />
        </xsl:when>
      </xsl:choose>
    </xsl:variable>

    <xsl:variable name="derivateOwnerId">
      <xsl:choose>
        <!-- it is derivate -->
        <xsl:when test="$derobject">
          <xsl:value-of select="mcrxml:getMCRObjectID($derobject)" />
        </xsl:when>
        <xsl:otherwise>
          <!--it is a regular mcrobj -->
          <xsl:value-of select="$mcrobject" />
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>

    <xsl:comment>
      Start amdSec - mets-amd.xsl
    </xsl:comment>
    <xsl:variable name="entity" select="document(concat('mcrobject:', $derivateOwnerId))" />
    <mets:amdSec ID="amd_{$sectionID}">
      <mets:rightsMD ID="rightsMD_263566811">
        <mets:mdWrap MIMETYPE="text/xml" MDTYPE="OTHER" OTHERMDTYPE="DVRIGHTS">
          <mets:xmlData>
            <dv:rights xmlns:dv="http://dfg-viewer.de/">
              <!-- owner name -->
              <dv:owner><xsl:value-of select="$MIR.DFGViewer.DV.Owner" /></dv:owner>
              <dv:ownerLogo><xsl:value-of select="$MIR.DFGViewer.DV.OwnerLogo" /></dv:ownerLogo>
              <dv:ownerSiteURL><xsl:value-of select="$MIR.DFGViewer.DV.OwnerSiteURL" /></dv:ownerSiteURL>
              <dv:ownerContact/>
              <dv:license>
                <xsl:choose>
                  <xsl:when test="$entity/mycoreobject/metadata/def.modsContainer/modsContainer/mods:mods/mods:accessCondition[@type='use and reproduction']">
                    <xsl:variable name="licenseClass" select="'mir_licenses'" />
                    <xsl:variable name="licenseId" select="substring-after($entity/mycoreobject/metadata/def.modsContainer/modsContainer/mods:mods/mods:accessCondition[@type='use and reproduction']/@xlink-href, '#')" />
                    <xsl:value-of select="mcrxml:getDisplayName($licenseClass, $licenseId)" />
                  </xsl:when>
                  <xsl:otherwise>
                    <xsl:value-of select="$license" />
                  </xsl:otherwise>
                </xsl:choose>
              </dv:license>
            </dv:rights>
          </mets:xmlData>
        </mets:mdWrap>
      </mets:rightsMD>
      <mets:digiprovMD>
        <xsl:attribute name="ID">
            <xsl:value-of select="concat('digiprovMD',$sectionID)" />
          </xsl:attribute>
        <mets:mdWrap MIMETYPE="text/xml" MDTYPE="OTHER" OTHERMDTYPE="DVLINKS">
          <mets:xmlData>
            <dv:links xmlns:dv="http://dfg-viewer.de/">
              <xsl:variable name="ppn"
                            select="substring-after($entity/mycoreobject/metadata/def.modsContainer/modsContainer/mods:mods/mods:identifier[@type='uri'], ':ppn:')" />
              <xsl:if test="$ppn">
                <dv:reference>
                  <xsl:variable name="catalogURL"
                                select="concat(substring-before($MIR.DFGViewer.DV.OPAC.CATALOG.URL, '{PPN}'), $ppn , substring-after($MIR.DFGViewer.DV.OPAC.CATALOG.URL, '{PPN}'))" />
                  <xsl:variable name="uriResolved"
                                select="document(concat($catalogURL,'?format=xml'))//rdf:Description[@rdf:about=normalize-space($catalogURL)]/*[local-name() = 'page']/@rdf:resource" />
                  <xsl:value-of select="$uriResolved" />
                </dv:reference>
              </xsl:if>
              <dv:presentation>
                <xsl:choose>
                  <xsl:when test="$mcrobject">
                    <xsl:value-of select="concat($WebApplicationBaseURL,'receive/',$mcrobject)" />
                  </xsl:when>
                  <xsl:when test="$derobject">
                    <xsl:value-of select="concat($WebApplicationBaseURL,'receive/',mcrxml:getMCRObjectID($derobject))" />
                  </xsl:when>
                </xsl:choose>
              </dv:presentation>
            </dv:links>
          </mets:xmlData>
        </mets:mdWrap>
      </mets:digiprovMD>
    </mets:amdSec>
    <xsl:comment>
      End amdSec - mets-amd.xsl
    </xsl:comment>
  </xsl:template>

</xsl:stylesheet>
