<?xml version="1.0"?>
<xsl:stylesheet version="3.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
                xmlns:p="info:srw/schema/5/picaXML-v1.0"
                xmlns:mods="http://www.loc.gov/mods/v3"
                xmlns:xlink="http://www.w3.org/1999/xlink">
  <xsl:mode on-no-match="shallow-copy"/>
  
  <xsl:import href="default/pica2mods-default-titleInfo.xsl" />
  <xsl:import href="default/pica2mods-default-name.xsl" />
  <xsl:import href="default/pica2mods-default-identifier.xsl" />
  <xsl:import href="default/pica2mods-default-language.xsl" />
  <xsl:import href="default/pica2mods-default-location.xsl" />
  <xsl:import href="default/pica2mods-default-physicalDescription.xsl" />
  <xsl:import href="default/pica2mods-default-originInfo.xsl" />
  <xsl:import href="default/pica2mods-default-genre.xsl" />
  <xsl:import href="default/pica2mods-default-recordInfo.xsl" />
  <xsl:import href="default/pica2mods-default-note.xsl" />
  <xsl:import href="default/pica2mods-default-abstract.xsl" />
  <xsl:import href="default/pica2mods-default-subject.xsl" />
  <xsl:import href="default/pica2mods-default-relatedItem.xsl" />

  <xsl:import href="_common/pica2mods-functions.xsl" />
  <xsl:param name="MCR.PICA2MODS.CONVERTER_VERSION" select="'Pica2Mods 2.0'" />
  <xsl:param name="MCR.PICA2MODS.DATABASE" select="'k10plus'" />

  <xsl:template match="p:record">
    <!-- This is a copy of https://github.com/MyCoRe-Org/pica2mods/blob/main/pica2mods-xslt/src/main/resources/xsl/pica2mods.xsl -->
    <!-- please add mir specific changes here -->
    <mods:mods>
      <xsl:call-template name="modsTitleInfo" />
      <xsl:call-template name="modsAbstract" />
      <xsl:call-template name="modsName" />
      <xsl:call-template name="modsIdentifier" />
      <xsl:call-template name="modsLanguage" />
      <xsl:call-template name="modsPhysicalDescription" />
      <xsl:call-template name="modsOriginInfo" />
      <xsl:call-template name="modsGenre" />
      <xsl:call-template name="modsLocation" />
      <xsl:call-template name="modsRecordInfo" />
      <xsl:call-template name="modsNote" />
      <xsl:call-template name="modsRelatedItem" />
      <xsl:call-template name="modsSubject" />
    </mods:mods>
  </xsl:template>

</xsl:stylesheet>
