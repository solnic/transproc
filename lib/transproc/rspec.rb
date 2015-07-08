# encoding: utf-8

# ==============================================================================
# Examples for testing transproc functions
# ==============================================================================

shared_context :call_transproc do
  let!(:initial)  { input.dup rescue input      }
  let!(:function) { described_class[*arguments] }
  let!(:result)   { function[input]             }
end

shared_examples :transforming_data do
  it '[returns the expected output]' do
    expect(result).to eql(output), <<-REPORT.gsub(/.+\|/, "")
      |
      |fn = #{described_class}#{Array[*arguments]}
      |
      |fn[#{input}]
      |
      |  expected: #{output}
      |       got: #{result}
    REPORT
  end
end

shared_examples :transforming_immutable_data do
  include_context :call_transproc

  it_behaves_like :transforming_data

  it '[keeps input unchanged]' do
    expect(input).to eql(initial), <<-REPORT.gsub(/.+\|/, "")
      |
      |fn = #{described_class}#{Array[*arguments]}
      |
      |expected: not to change #{initial}
      |     got: changed it to #{input}
    REPORT
  end
end

shared_examples :mutating_input_data do
  include_context :call_transproc

  it_behaves_like :transforming_data

  it '[changes input]' do
    expect(input).to eql(output), <<-REPORT.gsub(/.+\|/, "")
      |
      |fn = #{described_class}#{Array[*arguments]}
      |
      |fn[#{input}]
      |
      |expected: to change input to #{output}
      |     got: #{input}
    REPORT
  end
end
