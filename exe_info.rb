# http://mzc.narod.ru/Creating/Step008.htm
# This file prints PE-files (EXE, DLL...) headers information
# Example
#   ExeInfo.new "C:/Windows/Sustem32/ctfmon.exe"

class ExeInfo
  class Structure
    class StructureBuilder
      def initialize
        @fields = {}
        @last_byte = 0
      end
      def add_field name, length
        @fields[name.to_sym] = @last_byte..(@last_byte + length - 1)
        @last_byte += length
      end
    end

    def initialize file, header_address
      file.seek header_address
      @header = file.readpartial self.class.const_get :STRUCTURE_LENGHT
      p self.class.name
      p "-------"
      structure.each do |name, value|
        p "#{name} = #{@header[value]}"
      end
    end

    def self.set_structure &block
      builder = StructureBuilder.new
      builder.instance_eval &block
      const_set :STRUCTURE, builder.instance_variable_get(:@fields)
      const_set :STRUCTURE_LENGHT, builder.instance_variable_get(:@last_byte)
    end

    def get name
      value = @header[field_addr(name)]
      case value.size
      when 2 then value.unpack("v").first
      when 4 then value.unpack("V").first
      else value
      end
    end

    def structure
      self.class.const_get(:STRUCTURE)
    end

    def field_addr name
      structure[name.to_s.downcase.to_sym]
    end
  end

  class MsDosHeader < Structure
    set_structure do
      first_words = %w{magic last_page_byte_count pages_count relocations_count headers_size min_headers_alloc max_headers_alloc initial_ss_value initial_sp_value check_sum initial_ip_value initial_cs_value relocations_address overlays_count}
      first_words.each_with_index do |name, index|
        add_field name, 2
      end
      add_field :reserve_1, (0x1C..0x23).count
      add_field :oem_identifier, (0x24..0x25).count
      add_field :oem_info, (0x26..0x27).count
      add_field :reserve_2, (0x28..0x3B).count
      add_field :pe_header_address, (0x3C..0x3F).count
    end
  end

  class PeHeader < Structure
    set_structure do
      add_field :magic, (0..3).count
      add_field :cpu_type, (4..5).count
      add_field :sections_count, (6..7).count
      add_field :linker_date, (8..0x0B).count
      add_field :symbol_table_address, (0x0C..0x0F).count
      add_field :sumbol_table_size, (0x10..0x13).count
      add_field :optional_header_size, (0x14..0x15).count
      add_field :flag, (0x16..0x17).count
    end
  end

  class PeOptionalHeader < Structure
    set_structure do
      add_field :magic, 2
      add_field :major_linker_version, 1
      add_field :minor_linker_version, 1
      add_field :code_size, 4
      add_field :init_data_size, 4
      add_field :uninit_data_size, 4
      add_field :entry_point_address, 4
      add_field :code_base, 4
      add_field :data_base, 4
      add_field :image_base, 4
      add_field :section_align, 4
      add_field :file_align, 4
      add_field :major_os_verion, 2
      add_field :minor_os_verion, 2
      add_field :major_image_verion, 2
      add_field :minor_image_verion, 2
      add_field :major_subsystem_verion, 2
      add_field :minor_subsystem_verion, 2
      add_field :reserve_1, 4
      add_field :image_size, 4
      add_field :header_size, 4
      add_field :check_sum, 4
      add_field :subsystem, 2
      add_field :dll_flags, 2
      add_field :stack_reserve_size, 4
      add_field :stack_commit_size, 4
      add_field :heap_reserve_size, 4
      add_field :heap_commit_size, 4
      add_field :loader_flags, 4
      add_field :data_dir_size, 4
    end
  end

  class DataDirHeader < Structure
    set_structure do
      %w{export improt resource exception security base_reloc debug copyright cpu_spec tls config res1 res2 res3 res4 res5}.each do |name|
        add_field "#{name}_dir_addr", 4
        add_field "#{name}_dir_size", 4
      end
    end
  end

  class SectionHeader < Structure
    set_structure do
      add_field :section_name, 8
      add_field :virtual_size, 4
      add_field :virtual_addr, 4
      add_field :physical_size, 4
      add_field :physical_addr, 4
      add_field :reserve_1, 12
      add_field :section_flags, 4
    end
  end


  def initialize file
    @file = case file
    when File then file
    when String then File.new file, "rb"
    end

    @msdos_header = MsDosHeader.new @file, 0
    @pe_header = PeHeader.new @file, @msdos_header.get(:pe_header_address)
    optioanl_addr = (@msdos_header.get(:pe_header_address) + PeHeader::STRUCTURE_LENGHT)
    @pe_optional_header = PeOptionalHeader.new @file, optioanl_addr
    data_dir_addr = optioanl_addr + PeOptionalHeader::STRUCTURE_LENGHT
    @data_dir_header = DataDirHeader.new @file, data_dir_addr
    sections_addr = data_dir_addr + DataDirHeader::STRUCTURE_LENGHT
    @sections = []
    1.upto(@pe_header.get(:sections_count)) do |section|
      @sections.push SectionHeader.new @file, sections_addr + SectionHeader::STRUCTURE_LENGHT * (section - 1)
    end
  end
end
