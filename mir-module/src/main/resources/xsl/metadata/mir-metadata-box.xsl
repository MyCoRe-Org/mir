<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xlink="http://www.w3.org/1999/xlink"
  xmlns:i18n="xalan://org.mycore.services.i18n.MCRTranslation" xmlns:mods="http://www.loc.gov/mods/v3" xmlns:xalan="http://xml.apache.org/xalan"
  xmlns:mcrxsl="xalan://org.mycore.common.xml.MCRXMLFunctions"
  exclude-result-prefixes="i18n mods xlink xalan mcrxsl">
  <xsl:import href="xslImport:modsmeta:metadata/mir-metadata-box.xsl" />
  <xsl:include href="modsmetadata.xsl" />
  <xsl:include href="mir-mods-utils.xsl" />
  <!-- copied from http://www.loc.gov/standards/mods/v3/MODS3-4_HTML_XSLT1-0.xsl -->

  <xsl:key use="@type" name="title-by-type" match="//mods:mods/mods:titleInfo" />

  <xsl:template match="/">
    <xsl:variable name="mods" select="mycoreobject/metadata/def.modsContainer/modsContainer/mods:mods" />
    <!-- $mods-type contains genre -->
    <div id="mir-metadata">
      <xsl:apply-templates />
      <!--
      <dl>
        <dt>metaname</dt>
        <dd>metavalue</dd>
      </dl>
       -->
        <table class="mir-metadata">

            <xsl:for-each select="mycoreobject/metadata/def.modsContainer/modsContainer/mods:mods/mods:titleInfo[@type and
                                  count(. | key('title-by-type',@type)[1])=1]">
              <tr>
                <td valign="top" class="metaname">
                  <xsl:choose>
                    <xsl:when test="@displayLabel">
                      <xsl:value-of select="@displayLabel" />
                    </xsl:when>
                    <xsl:otherwise>
                      <xsl:value-of select="i18n:translate(concat('mir.title.type.', @type))" />
                    </xsl:otherwise>
                  </xsl:choose>
                  <xsl:text>:</xsl:text>
                </td>
                <td class="metavalue">
                  <xsl:for-each select="key('title-by-type',@type)">
                    <xsl:if test="position()!=1">
                      <br />
                    </xsl:if>
                    <xsl:apply-templates select="//modsContainer/mods:mods" mode="mods.title">
                      <xsl:with-param name="type" select="@type" />
                      <xsl:with-param name="asHTML" select="true()" />
                      <xsl:with-param name="withSubtitle" select="true()" />
                      <xsl:with-param name="position" select="position()" />
                    </xsl:apply-templates>
                    <xsl:if test="@type='translated'">
                      <xsl:text> (</xsl:text>
                      <xsl:value-of select="mcrxsl:getDisplayName('rfc5646',@xml:lang)" />
                      <xsl:text>)</xsl:text>
                    </xsl:if>
                  </xsl:for-each>
                </td>
              </tr>
            </xsl:for-each>

            <xsl:call-template name="printMetaDate.mods">
              <xsl:with-param name="nodes" select="mycoreobject/metadata/def.modsContainer/modsContainer/mods:mods/mods:name[@type='conference']/mods:namePart[not(@type)]" />
              <xsl:with-param name="label" select="i18n:translate('component.mods.metaData.dictionary.conference.title')" />
            </xsl:call-template>


            <xsl:variable name="institutesURI" select="document('classification:metadata:-1:children:mir_institutes')/mycoreclass/label[@xml:lang='x-uri']/@text" />

            <!-- mods:name grouped by mods:role/mods:roleTerm excluding author-->
            <xsl:for-each
              select="mycoreobject/metadata/def.modsContainer/modsContainer/mods:mods/mods:name[not(@ID) and
                      (@type='personal' or (@type='corporate' and not(@authorityURI = $institutesURI)))
                      and not(mods:role/mods:roleTerm='aut') and count(. | key('name-by-role',mods:role/mods:roleTerm)[1])=1]">
              <!-- for every role -->
              <xsl:choose>
                <!-- check if 'aut' and 'edt' show 'edt', otherwise 'edt' is already shown in abstract-box -->
                <xsl:when test="mods:role/mods:roleTerm='edt' and not(../mods:name/mods:role/mods:roleTerm='aut')">
                  <!-- do nothing -->
                </xsl:when>
                <!-- check if role term is given -->
                <xsl:when test="not(mods:role/mods:roleTerm)">
                  <!-- do nothing -->
                </xsl:when>
                <xsl:otherwise>
                  <tr>
                    <td valign="top" class="metaname">
                      <xsl:choose>
                        <xsl:when test="mods:role/mods:roleTerm[@authority='marcrelator' and @type='code']">
                          <xsl:apply-templates select="mods:role/mods:roleTerm[@authority='marcrelator' and @type='code']"
                            mode="printModsClassInfo" />
                          <xsl:value-of select="':'" />
                        </xsl:when>
                        <xsl:when test="mods:role/mods:roleTerm[@authority='marcrelator']">
                          <xsl:value-of
                            select="concat(i18n:translate(concat('component.mods.metaData.dictionary.',mods:role/mods:roleTerm[@authority='marcrelator'])),':')" />
                        </xsl:when>
                      </xsl:choose>
                    </td>
                    <td class="metavalue">
                      <xsl:for-each select="key('name-by-role',mods:role/mods:roleTerm)">
                        <xsl:if test="position()!=1">
                          <xsl:value-of select="'; '" />
                        </xsl:if>
                        <xsl:apply-templates select="." mode="mirNameLink" />
                      </xsl:for-each>
                        <xsl:if test="$mods/mods:name/mods:etal">
                            <em>et.al.</em>
                        </xsl:if>
                    </td>
                  </tr>
                </xsl:otherwise>
              </xsl:choose>
            </xsl:for-each>

            <xsl:for-each select="mycoreobject">
              <xsl:if test="./structure/parents/parent/@xlink:href">
                <xsl:call-template name="printMetaDate.mods.relatedItem">
                  <xsl:with-param name="parentID" select="./structure/parents/parent/@xlink:href" />
                  <xsl:with-param name="label" select="i18n:translate('component.mods.metaData.dictionary.confpubIn')" />
                </xsl:call-template>
              </xsl:if>
            </xsl:for-each>
            <xsl:for-each select="mycoreobject/metadata/def.modsContainer/modsContainer/mods:mods/mods:relatedItem[not(@type='host' and @xlink:href)]">
              <xsl:variable name="relItemLabel">
                <xsl:choose>
                  <xsl:when test="@displayLabel">
                    <xsl:value-of select="@displayLabel"/>
                  </xsl:when>
                  <xsl:when test="@type">
                    <xsl:value-of select="i18n:translate(concat('mir.relatedItem.', @type))"/>
                  </xsl:when>
                  <xsl:when test="@otherType">
                    <xsl:value-of select="i18n:translate(concat('mir.relatedItem.', @otherType))"/>
                  </xsl:when>
                  <xsl:otherwise>
                    <xsl:value-of select="i18n:translate('mir.relatedItem')"/>
                  </xsl:otherwise>
                </xsl:choose>
              </xsl:variable>
              <xsl:choose>
                <xsl:when test="@xlink:href">
                  <xsl:call-template name="printMetaDate.mods.relatedItems">
                    <xsl:with-param name="parentID" select="./@xlink:href" />
                    <xsl:with-param name="label" select="$relItemLabel" />
                  </xsl:call-template>
                </xsl:when>
                <xsl:otherwise>
                  <xsl:call-template name="printMetaDate.mods.relatedItems">
                    <xsl:with-param name="parentID" select="''" />
                    <xsl:with-param name="label" select="$relItemLabel" />
                  </xsl:call-template>
                </xsl:otherwise>
              </xsl:choose>
            </xsl:for-each>
            <xsl:call-template name="printMetaDate.mods">
              <xsl:with-param name="nodes" select="mycoreobject/metadata/def.modsContainer/modsContainer/mods:mods/mods:relatedItem[@type='host']/mods:part/mods:detail[@type='volume']/mods:number" />
              <xsl:with-param name="label" select="i18n:translate('component.mods.metaData.dictionary.volume.article')" />
            </xsl:call-template>
            <xsl:call-template name="printMetaDate.mods">
              <xsl:with-param name="nodes" select="mycoreobject/metadata/def.modsContainer/modsContainer/mods:mods/mods:relatedItem[@type='host']/mods:part/mods:detail[@type='issue']/mods:number" />
              <xsl:with-param name="label" select="i18n:translate('mir.details.issue')" />
            </xsl:call-template>
            <xsl:call-template name="printMetaDate.mods">
              <xsl:with-param name="nodes" select="mycoreobject/metadata/def.modsContainer/modsContainer/mods:mods/mods:originInfo/mods:edition" />
            </xsl:call-template>
            <xsl:apply-templates select="mycoreobject/metadata/def.modsContainer/modsContainer/mods:mods/mods:originInfo[@eventType='creation']/mods:dateCreated"
              mode="present" />
            <xsl:apply-templates select="mycoreobject/metadata/def.modsContainer/modsContainer/mods:mods/mods:originInfo[@eventType='creation']/mods:dateOther[@type='submitted']"
              mode="present">
              <xsl:with-param name="label" select="i18n:translate('component.mods.metaData.dictionary.dateSubmitted')" />
            </xsl:apply-templates>
            <xsl:apply-templates select="mycoreobject/metadata/def.modsContainer/modsContainer/mods:mods/mods:originInfo[@eventType='creation']/mods:dateOther[@type='accepted']"
              mode="present">
              <xsl:with-param name="label" select="i18n:translate('component.mods.metaData.dictionary.dateAccepted')" />
            </xsl:apply-templates>
            <xsl:apply-templates select="mycoreobject/metadata/def.modsContainer/modsContainer/mods:mods/mods:originInfo[@eventType='review']/mods:dateOther[@type='reviewed']"
              mode="present">
                <xsl:with-param name="label" select="i18n:translate('component.mods.metaData.dictionary.dateReviewed')" />
            </xsl:apply-templates>
            <xsl:apply-templates select="mycoreobject/metadata/def.modsContainer/modsContainer/mods:mods/mods:originInfo[@eventType='collection']/mods:dateCaptured"
              mode="present" />
            <xsl:apply-templates select="mycoreobject/metadata/def.modsContainer/modsContainer/mods:mods/mods:originInfo[@eventType='publication']/mods:dateIssued[@encoding='w3cdtf']"
              mode="present" />
            <xsl:apply-templates select="mycoreobject/metadata/def.modsContainer/modsContainer/mods:mods/mods:originInfo[@eventType='update']/mods:dateModified"
              mode="present" />
            <xsl:apply-templates mode="present" select="mycoreobject/metadata/def.modsContainer/modsContainer/mods:mods/mods:identifier[@type!='open-aire' and @type!='intern' and @type!='issn']" />
            <xsl:for-each select="mycoreobject/metadata/def.modsContainer/modsContainer/mods:mods/mods:identifier[@type='issn']">
                <tr>
                    <td class="metaname" valign="top">
                        <xsl:value-of select="i18n:translate('mir.identifier.issn')" />
                    </td>
                    <td class="metavalue">
                        <xsl:value-of select="."/>
                    </td>
                </tr>
            </xsl:for-each>
            <xsl:apply-templates mode="present" select="mycoreobject/metadata/def.modsContainer/modsContainer/mods:mods/mods:language" />
            <xsl:for-each select="mycoreobject/metadata/def.modsContainer/modsContainer/mods:mods/mods:typeOfResource">
              <tr>
                <td class="metaname" valign="top">
                  <xsl:value-of select="concat(i18n:translate('component.mods.metaData.dictionary.typeOfResource'),':')" />
                </td>
                <td class="metavalue">
                  <xsl:value-of select="document(concat('classification:metadata:0:children:typeOfResource:', translate(./text(),' ','_')))//category/label[@xml:lang=$CurrentLang]/@text"/>
                </td>
              </tr>
            </xsl:for-each>
            <xsl:call-template name="printMetaDate.mods">
              <xsl:with-param name="nodes"
                select="mycoreobject/metadata/def.modsContainer/modsContainer/mods:mods/mods:physicalDescription/mods:extent" />
            </xsl:call-template>
            <xsl:apply-templates mode="openaire" select="mycoreobject/metadata/def.modsContainer/modsContainer/mods:mods/mods:identifier[@type='open-aire']" />
            <xsl:call-template name="printMetaDate.mods">
              <xsl:with-param name="nodes"
                select="mycoreobject/metadata/def.modsContainer/modsContainer/mods:mods/mods:originInfo[not(@eventType) or @eventType='publication']/mods:place/mods:placeTerm[not(@authority='marccountry')]" />
            </xsl:call-template>
            <xsl:call-template name="printMetaDate.mods">
              <xsl:with-param name="nodes"
                select="mycoreobject/metadata/def.modsContainer/modsContainer/mods:mods/mods:originInfo[@eventType='creation']/mods:place/mods:placeTerm[not(@authority='marccountry')]" />
              <xsl:with-param name="label" select="i18n:translate('component.mods.metaData.dictionary.placeTerm.creation')" />
            </xsl:call-template>
            <xsl:call-template name="printMetaDate.mods">
              <xsl:with-param name="nodes" select="mycoreobject/metadata/def.modsContainer/modsContainer/mods:mods/mods:originInfo[not(@eventType) or @eventType='publication']/mods:publisher" />
            </xsl:call-template>
            <xsl:call-template name="printMetaDate.mods">
                <xsl:with-param name="nodes"
                                select="mycoreobject/metadata/def.modsContainer/modsContainer/mods:mods/mods:originInfo[@eventType='creation']/mods:publisher"/>
                <xsl:with-param name="label"
                                select="i18n:translate('component.mods.metaData.dictionary.publisher.creation')"/>
            </xsl:call-template>
            <!--
              <xsl:call-template name="printMetaDate.mods">
                <xsl:with-param name="nodes" select="//mods:mods/mods:subject/mods:topic" />
                <xsl:with-param name="label" select="i18n:translate('component.mods.metaData.dictionary.subject')" />
                <xsl:with-param name="sep" select="'; '" />
                <xsl:with-param name="property" select="'keyword'" />
              </xsl:call-template>
           -->
            <xsl:for-each
                    select="mycoreobject/metadata/def.modsContainer/modsContainer/mods:mods/mods:subject[(count(mods:geographic)&gt;0 or count(mods:cartographics)&gt;0) and (count(mods:geographic) + count(mods:cartographics)) = count(mods:*)]">
                <xsl:call-template name="printMetaDate.mods">
                    <xsl:with-param name="nodes" select="mods:geographic"/>
                </xsl:call-template>
                <xsl:for-each select="mods:cartographics/mods:coordinates">
                    <tr>
                        <td class="metaname" valign="top">
                            <xsl:value-of select="i18n:translate('mir.cartographics.coordinates')"/>
                        </td>
                        <td class="metavalue">
                            <xsl:call-template name="displayCoordinates"/>
                        </td>
                    </tr>
                </xsl:for-each>
            </xsl:for-each>


            <xsl:if test="count(mycoreobject/metadata/def.modsContainer/modsContainer/mods:mods/mods:subject[not((count(mods:geographic)&gt;0 or count(mods:cartographics)&gt;0) and (count(mods:geographic) + count(mods:cartographics)) = count(mods:*))])&gt;0">
                <tr>
                    <td class="metaname" valign="top">
                        <xsl:value-of select="concat(i18n:translate('component.mods.metaData.dictionary.subject'),':')"/>
                    </td>
                    <td class="metavalue">
                        <xsl:for-each
                                select="mycoreobject/metadata/def.modsContainer/modsContainer/mods:mods/mods:subject[not((count(mods:geographic)&gt;0 or count(mods:cartographics)&gt;0) and (count(mods:geographic) + count(mods:cartographics)) = count(mods:*))]">
                        <ol class="topic-list">
                                <xsl:for-each select="mods:*">
                                    <li class="topic-element">
                                        <xsl:apply-templates select="." mode="displaySubject"/>
                                    </li>
                                </xsl:for-each>
                            </ol>
                        </xsl:for-each>
                    </td>
                </tr>
            </xsl:if>

            <xsl:apply-templates mode="present"
                                 select="mycoreobject/metadata/def.modsContainer/modsContainer/mods:mods/mods:classification[not(@generator)]"/>
            <xsl:apply-templates mode="present"
                                 select="mycoreobject/metadata/def.modsContainer/modsContainer/mods:mods/mods:part/mods:extent"/>
            <xsl:apply-templates mode="present"
                                 select="mycoreobject/metadata/def.modsContainer/modsContainer/mods:mods/mods:location/mods:url"/>
            <xsl:call-template name="printMetaDate.mods">
                <xsl:with-param name="nodes"
                                select="mycoreobject/metadata/def.modsContainer/modsContainer/mods:mods/mods:location/mods:physicalLocation[not(starts-with(@xlink:href, '#'))]"/>
            </xsl:call-template>
            <xsl:call-template name="printMetaDate.mods">
                <xsl:with-param name="nodes"
                                select="mycoreobject/metadata/def.modsContainer/modsContainer/mods:mods/mods:location/mods:shelfLocator"/>
                <xsl:with-param name="label" select="i18n:translate('mir.shelfmark')"/>
            </xsl:call-template>
            <xsl:apply-templates mode="present"
                                 select="mycoreobject/metadata/def.modsContainer/modsContainer/mods:mods/mods:name[@type='corporate'][@ID or @authorityURI=$institutesURI]"/>
            <xsl:apply-templates mode="present"
                                 select="mycoreobject/metadata/def.modsContainer/modsContainer/mods:mods/mods:extension[@displayLabel='characteristics']"/>
            <xsl:for-each select="mycoreobject/metadata/def.modsContainer/modsContainer/mods:mods/mods:note">
                <xsl:variable name="myURI"
                              select="concat('classification:metadata:0:children:noteTypes:',mcrxsl:regexp(@type,' ', '_'))"/>
                <xsl:variable name="x-access">
                    <xsl:value-of select="document($myURI)//label[@xml:lang='x-access']/@text"/>
                </xsl:variable>
                <xsl:variable name="noteLabel">
                    <xsl:value-of select="document($myURI)//category/label[@xml:lang=$CurrentLang]/@text"/>
                </xsl:variable>
                <xsl:if test="contains($x-access, 'guest')">
                    <xsl:call-template name="printMetaDate.mods">
                        <xsl:with-param select="." name="nodes"/>
                        <xsl:with-param select="$noteLabel" name="label"/>
                    </xsl:call-template>
                </xsl:if>
            </xsl:for-each>
        </table>

    </div>
      <xsl:apply-imports/>
  </xsl:template>

    <xsl:template name="displayCoordinates">
        <xsl:choose>
            <xsl:when test="contains(., ',')">
                <span class="displayCoords" data-fullcoords="{.}">
                    <xsl:value-of select="substring-before(., ',')"/>
                    <a class="flipCoords" role="button">...</a>
                </span>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="."/>
            </xsl:otherwise>
        </xsl:choose>
        <span>
            <button type="button" class="show_openstreetmap btn btn-secondary btn-inline btn-sm" data-coords="{.}">
                OpenStreetMap
            </button>
        </span>
        <span class="openstreetmap-container collapse">
            <div class="map"> </div>
        </span>
    </xsl:template>

    <xsl:template match="mods:geographic" mode="displaySubject">
        <xsl:call-template name="authorityLink">
            <xsl:with-param name="content">
                <xsl:value-of select="."/>
            </xsl:with-param>
        </xsl:call-template>
        <xsl:call-template name="displayInfoIconWithBox">
            <xsl:with-param name="boxContent">
                <dl>
                    <dt>
                        <xsl:value-of select="i18n:translate('mir.details.popover.type')"/>
                    </dt>
                    <dd>
                        <i class="fas fa-map-location-dot mr-2"> </i>
                        <xsl:value-of select="i18n:translate('mir.details.popover.type.geographic')"/>
                    </dd>
                </dl>
            </xsl:with-param>
        </xsl:call-template>
    </xsl:template>

    <xsl:template match="mods:cartographics" mode="displaySubject">
        <!-- <i class="fas fa-map-marker-alt mr-2"> </i> -->
        <xsl:call-template name="authorityLink">
                <xsl:with-param name="content">
                    <xsl:call-template name="displayCoordinates"/>
                </xsl:with-param>
        </xsl:call-template>
    </xsl:template>

    <xsl:template match="mods:topic" mode="displaySubject">
        <xsl:call-template name="authorityLink">
            <xsl:with-param name="content">
                <xsl:value-of select="."/>
            </xsl:with-param>
        </xsl:call-template>

        <xsl:call-template name="displayInfoIconWithBox">
            <xsl:with-param name="boxContent">
                <dl>
                    <dt>
                        <xsl:value-of select="i18n:translate('mir.details.popover.type')"/>
                    </dt>
                    <dd>
                        <i class="fas fa-tag mr-2"> </i>
                        <xsl:value-of select="i18n:translate('mir.details.popover.type.topic')"/>
                    </dd>
                </dl>
            </xsl:with-param>
        </xsl:call-template>
    </xsl:template>

    <xsl:template match="mods:name" mode="displaySubject">
        <xsl:call-template name="authorityLink">
            <xsl:with-param name="content">
                <xsl:value-of select="mods:displayForm"/>
            </xsl:with-param>
        </xsl:call-template>


        <xsl:variable name="nameIds">
            <xsl:call-template name="getNameIdentifiers">
                <xsl:with-param name="entity" select="."/>
            </xsl:call-template>
        </xsl:variable>
        <xsl:variable name="nameIdentifiers" select="xalan:nodeset($nameIds)/nameIdentifier"/>
        <xsl:variable name="affiliation" select="mods:affiliation/text()"/>

        <xsl:call-template name="displayInfoIconWithBox">
            <xsl:with-param name="boxContent">
                <dl>
                    <dt>
                        <xsl:value-of select="i18n:translate('mir.details.popover.type')"/>
                    </dt>
                    <dd>
                        <xsl:choose>
                            <xsl:when test="@type='family'">
                                <i class="fas fa-people-roof mr-2"> </i>
                            </xsl:when>
                            <xsl:when test="@type='personal'">
                                <i class="fas fa-person mr-2"> </i>
                            </xsl:when>
                            <xsl:when test="@type='corporate'">
                                <i class="fas fa-building mr-2"> </i>
                            </xsl:when>
                            <xsl:when test="@type='conference'">
                                <i class="fas fa-people-line mr-2"> </i>
                            </xsl:when>
                        </xsl:choose>
                        <xsl:value-of select="i18n:translate(concat('mir.details.popover.type.', @type))"/>
                    </dd>
                    <xsl:if test="count($nameIdentifiers) &gt; 0">
                        <xsl:for-each select="$nameIdentifiers">
                            <dt>
                                <xsl:value-of select="@label"/>
                            </dt>
                            <dd>
                                <a href="{@uri}{@id}">
                                    <xsl:value-of select="@id"/>
                                </a>
                            </dd>
                        </xsl:for-each>
                    </xsl:if>
                    <xsl:if test="string-length($affiliation) &gt; 0">
                        <dt>
                            <xsl:value-of select="i18n:translate('mir.affiliation')"/>
                        </dt>
                        <dd>
                            <xsl:value-of select="$affiliation"/>
                        </dd>
                    </xsl:if>
                </dl>
            </xsl:with-param>
        </xsl:call-template>


    </xsl:template>

    <xsl:template match="mods:titleInfo" mode="displaySubject">
        <xsl:call-template name="authorityLink">
            <xsl:with-param name="content">
                <xsl:value-of select="mods:title"/>
                <xsl:if test="mods:subTitle">
                    <xsl:text>: </xsl:text>
                    <xsl:value-of select="mods:subTitle"/>
                </xsl:if>
                <xsl:if test="mods:partNumber">
                    <xsl:text> </xsl:text>
                    <xsl:value-of select="mods:partNumber"/>
                </xsl:if>
                <xsl:if test="mods:partName">
                    <xsl:text> </xsl:text>
                    <xsl:value-of select="mods:partName"/>
                </xsl:if>
            </xsl:with-param>
        </xsl:call-template>
        <xsl:call-template name="displayInfoIconWithBox">
            <xsl:with-param name="boxContent">
                <dl>
                    <dt>
                        <xsl:value-of select="i18n:translate('mir.details.popover.type')"/>
                    </dt>
                    <dd>
                        <i class="fa fa-newspaper mr-2"> </i>
                        <xsl:value-of select="i18n:translate('mir.details.popover.type.titleInfo')"/>
                    </dd>
                </dl>
            </xsl:with-param>
        </xsl:call-template>
    </xsl:template>

    <xsl:template name="authorityLink">
        <xsl:param name="content" />
        <xsl:choose>
            <xsl:when test="(@authority or @authorityURI) and @valueURI">
                <a href="{@valueURI}" target="_blank">
                    <xsl:copy-of select="$content" />
                </a>
            </xsl:when>
            <xsl:otherwise>
                <xsl:copy-of select="$content" />
            </xsl:otherwise>
        </xsl:choose>

    </xsl:template>

    <xsl:template name="displayInfoIconWithBox">
        <xsl:param name="boxContent" />
        <xsl:variable name="boxId" select="generate-id(.)"/>
        <div id="{$boxId}-content" class="d-none">
            <xsl:copy-of select="$boxContent"/>
        </div>

        <a id="{$boxId}" class="boxPopover" title="{i18n:translate('mir.details.popover.title')}">
            <span class="fa fa-info-circle"/>
        </a>
    </xsl:template>

</xsl:stylesheet>
